extends KinematicBody2D

onready var velocity_multiplier = 1
# dynamic player variables

onready var velocity = Vector2.ZERO
onready var camera = $Camera2D
onready var last_input = null

# static player varaibles
onready var gravity = 0

# player states
onready var can_climb = false
onready var is_climbing = false
onready var attacking = false
onready var player_state
onready var sprite = $CompositeSprite

var floating_text = preload("res://scenes/userInerface/FloatingText.tscn")
onready var input
onready var hit_timer = $Timer

onready var horizontal_speed: int
onready var vertical_speed: int
onready var dmg_number_height = -15
#########
#Temp
onready var recon_arr = {
	"input_arr": [],
	"velocity": Vector2(0,0),
	"mns": null,
	"end_pos": Vector2(0,0),
	"m_vector": null,
}
########

func _ready():
	
	gravity = 800
	# warning-ignore:return_value_discarded
	Signals.connect("dialog_closed", self, "movable_switch")
# warning-ignore:return_value_discarded
	Signals.connect("attack", self, "attack")
# warning-ignore:return_value_discarded
	Signals.connect("use_skill", self, "use_skill")
# warning-ignore:return_value_discarded
	Signals.connect("take_damage", self, "start_hit_timer")
	Global.player_node = self
	Global.in_game = true

func _physics_process(delta):
	if Global.in_game:

		get_directional_speed()
	# warning-ignore:shadowed_variable
		var input = get_input()
		movement_loop(delta, input)
		define_player_state(input)
		Global.player_position = self.global_position

func define_player_state(input_array):
	player_state = {"T": Server.client_clock, "P": input_array}

	# if not afk, add input and position to tick key
	var input_dictionary = {
		"T" : player_state["T"],
		"P": self.global_position,
		}
	Global.input_queue.append(input_dictionary)
	Server.send_player_state(player_state)

func get_input():
# warning-ignore:shadowed_variable
	var temp_input = [0,0,0,0,0,0]
	if not SceneHandler.transition:
	
		if Input.is_action_pressed("ui_up"):
			temp_input[0] = 1
		if Input.is_action_pressed("ui_left"):
			temp_input[1] = 1
		if Input.is_action_pressed("ui_down"):
			temp_input[2] = 1
		if Input.is_action_pressed("ui_right"):
			temp_input[3] = 1
		if Input.is_action_pressed("jump"):
			temp_input[4] = 1
		if Input.is_action_pressed("loot") and recon_arr["input_arr"][5] != 1:
			temp_input[5] = 1
		
	recon_arr["input_arr"] = temp_input
	return temp_input

func movement_loop(delta, input_arr):
	change_direction()
	var move_vector = get_movement_vector(input_arr)
	recon_arr["m_vector"] = move_vector
	# change get velocity
	get_velocity(move_vector, input_arr, delta)
	recon_arr["velocity"] = velocity
	# warning-ignore:return_value_discarded
	recon_arr["start_pos"] = self.global_position
	move_and_slide(velocity, Vector2.UP)
	recon_arr["mns"] = move_and_slide(velocity, Vector2.UP)
	recon_arr["end_pos"] = self.global_position
	
	if is_on_floor() or !is_climbing:
		velocity = move_and_slide(velocity, Vector2.UP)
	if is_climbing:
		sprite.set_climb()
		velocity.x = 0
	else:
		sprite.unset_climb()
	update_animation(move_vector)
	
# warning-ignore:shadowed_variable
func get_movement_vector(input):
	var moveVector = Vector2.ZERO
	# calculating x vector, allow x-axis jump off ropes or idle on floor
	if (!attacking && is_on_floor()) or (input[1] == 1 or input[3] == 1) and input[4] == 1:
		moveVector.x = (input[3] - input[1]) * velocity_multiplier
	else:
		moveVector.x = 0	
	# calculating y vector, allow jump off ropes
	if is_climbing:
		if (input[1] == 1 or input[3] == 1) and input[4] == 1:
			moveVector.y = -1
			AudioControl.play_audio("jump")
		else:
			moveVector.y = 0
	else:
		if input[4] == 1 && !attacking:
			moveVector.y = -1
			AudioControl.play_audio("jump")
		else:
			moveVector.y = 0
	return moveVector

# warning-ignore:shadowed_variable
func get_velocity(move_vector, input, delta):
	velocity.x += move_vector.x * horizontal_speed
	# slow down movement
	if(move_vector.x == 0):
		# allows forward jumping
		if(is_on_floor()):
			# instant stop
			velocity.x = 0

	# allows maximum velocity
	velocity.x = clamp(velocity.x, -horizontal_speed, horizontal_speed)
	if can_climb:
		if is_climbing:
			velocity.y = 0
			# up press
			if input[0] == 1:
				sprite.climb_anim.play("climb")
				velocity.y = -100
			# down press
			elif input[2] == 1 :
				sprite.climb_anim.play("climb")
				velocity.y = 100
				if is_on_floor():
					is_climbing = false
					sprite.unset_climb()
			# jump off rope
			elif input[4] == 1 && (input[1] == 1 or input[3] == 1):
				is_climbing = false
				sprite.unset_climb()
				velocity.y = move_vector.y * (vertical_speed)
				velocity.x = move_vector.x * 200
		# can climb but not climbing
		else:
			#if moving
			if (move_vector.y < 0 && is_on_floor()):
					velocity.y = move_vector.y * (Global.player.stats.base.jumpSpeed + Global.player.stats.equipment.jumpSpeed + Global.player.stats.buff.jumpSpeed)
			# press up on ladder initiates climbing
			elif input[0] == 1:
					is_climbing = true
					velocity.y = 0
					velocity.x = 0
			# over lapping ladder pressing nothing allows gravity
			else:
				velocity.y += gravity * delta
	# not climbable state
	else:
		# normal movement
		if (move_vector.y < 0 && is_on_floor()):
			velocity.y = move_vector.y * (Global.player.stats.base.jumpSpeed + Global.player.stats.equipment.jumpSpeed + Global.player.stats.buff.jumpSpeed)
		else:
			velocity.y += gravity * delta
	if !can_climb:
		is_climbing = false

func update_animation(move_vector):
	if(attacking):
		last_input = null
		pass

	# send rpc to server
	elif last_input:
		if(!is_climbing && Global.movable):
			if last_input in ["slash", "attack"]:
				attacking = true
				#sprite.play("slash",-1, GameData.weapon_speed[str(Global.player.equipment.rweapon.speed)])
				sprite.normal_anim.play("slash",-1, GameData.weapon_speed[str(Global.player.equipment.rweapon.attackSpeed)])
				#### insert sound play
				determine_weapon_noise()
				"""
				can insert determine_weapon_noise into compositesprite animations
				determine attack speed -> adjust when sound is played (delay for slower wep)
				"""
				if last_input == "attack":
					Server.send_input(0)
			else:
				attacking = true
				sprite.normal_anim.play("ready",-1, GameData.weapon_speed[str(Global.player.equipment.rweapon.attackSpeed)])
				#### insert sound play
				#determine_weapon_noise()
		last_input = null
	else:
		if(!is_on_floor()):
			pass
			sprite.normal_anim.play("jump")
		elif(move_vector.x != 0):
			sprite.normal_anim.play("walk")
		else:
			if hit_timer.time_left != 0:
				sprite.normal_anim.play("hit")
			else:
				sprite.normal_anim.play("idle")

func determine_weapon_noise() -> void:
	if Global.player.equipment.rweapon.weaponType in ["dagger", "1h_sword", "1h_axe", "staff", "wand"]:
		AudioControl.play_audio("1h_swing")
	elif Global.player.equipment.rweapon.weaponType in ["1h_blunt", "2h_blunt"]:
		AudioControl.play_audio("blunt_swing")
	elif Global.player.equipment.rweapon.weaponType in ["2h_sword", "2h_axe"]:
		AudioControl.play_audio("2h_swing")
	
func movable_switch():
	Global.movable = true
	
func flip_sprite(d):
	for _i in sprite.normal.get_children():
		if _i.get_class() != "AnimationPlayer":
			if d:
				_i.set_flip_h(true)
			else:
				_i.set_flip_h(false)

func change_direction():
	if Input.is_action_pressed("move_right") && !attacking && !Input.is_action_pressed("move_left"):
		if velocity.x < 0 && is_on_floor():
			velocity.x = 0
		flip_sprite(false)
	elif Input.is_action_pressed("move_left") && !attacking && !Input.is_action_pressed("move_right"):
		if velocity.x > 0 && is_on_floor():
			velocity.x  = 0
		flip_sprite(true)

func heal(heal_value: int) -> void:
	var text = floating_text.instance()
	text.type = "PH"
	text.amount = str(heal_value)
	add_child(text)
	
func took_damage(damage_value: int) -> void:
	var text = floating_text.instance()
	text.position.y = dmg_number_height
	text.type = "PN"
	text.amount = str(damage_value)
	add_child(text)
	
#func _unhandled_input(event):
# pass
	
func attack() -> void:
	last_input = "attack"
	
func use_skill(animation_id: String) -> void:
	print(animation_id)
	last_input = animation_id
	
func start_hit_timer(damage_taken: int) -> void:
	hit_timer.start()
	took_damage(damage_taken)

func _on_Timer_timeout():
	print("hit timer = 0 play idle")

func get_directional_speed() -> void:
	vertical_speed = Global.player.stats.base.jumpSpeed + Global.player.stats.equipment.jumpSpeed + Global.player.stats.buff.jumpSpeed
	horizontal_speed = Global.player.stats.base.movementSpeed + Global.player.stats.equipment.movementSpeed + Global.player.stats.buff.movementSpeed
