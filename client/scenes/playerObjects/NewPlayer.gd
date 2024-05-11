extends KinematicBody2D

onready var velocity_multiplier = 1
# dynamic player variables
onready var jump_speed
onready var max_horizontal_speed
onready var velocity = Vector2.ZERO

# static player varaibles
onready var gravity = 800
onready var temp_delta
# player states
onready var can_climb = false
onready var is_climbing = false
onready var attacking = false
onready var player_state
var held_down = false
onready var sprite = $CompositeSprite/AnimationPlayer

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
	max_horizontal_speed = (Global.player.stats.base.movementSpeed)
	# warning-ignore:return_value_discarded
	Signals.connect("dialog_closed", self, "movable_switch")
	jump_speed = (Global.player.stats.base.jumpSpeed)
	Global.in_game = true

func _physics_process(delta):
	temp_delta = delta
	""""
	if Global.movable:
		get_input()
	"""
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
	var input = [0,0,0,0,0,0]
	if Input.is_action_pressed("ui_up"):
		input[0] = 1
	if Input.is_action_pressed("ui_left"):
		input[1] = 1
	if Input.is_action_pressed("ui_down"):
		input[2] = 1
	if Input.is_action_pressed("ui_right"):
		input[3] = 1
	if Input.is_action_pressed("jump"):
		input [4] = 1
	if Input.is_action_pressed("loot"):
		input [5] = 1
	recon_arr["input_arr"] = input
	return input

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
		velocity.x = 0
	update_animation(move_vector)
	#if recon_arr["input_arr"] != [0,0,0,0,0] and recon_arr["input_arr"] != []:
		#print(recon_arr)
	
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
		else:
			moveVector.y = 0
	else:
		if input[4] == 1 && !attacking:
			moveVector.y = -1
		else:
			moveVector.y = 0
	return moveVector

func get_velocity(move_vector, input, delta):
	velocity.x += move_vector.x * max_horizontal_speed
	# slow down movement
	if(move_vector.x == 0):
		# allows forward jumping
		if(is_on_floor()):
			# instant stop
			velocity.x = 0

	# allows maximum velocity
	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	if can_climb:
		if is_climbing:
			velocity.y = 0
			# up press
			if input[0] == 1:
				velocity.y = -100
			# down press
			elif input[2] == 1 :
				velocity.y = 100
				if is_on_floor():
					is_climbing = false
					#Global.send_climb_data(self.name, 1)
			# jump off rope
			elif input[4] == 1 && (input[1] == 1 or input[3] == 1):
				is_climbing = false
				#Global.send_climb_data(self.name, 1)
				velocity.y = move_vector.y * jump_speed * .8
				velocity.x = move_vector.x * 200
		# can climb but not climbing
		else:
			#if moving
			if (move_vector.y < 0 && is_on_floor()):
					velocity.y = move_vector.y * jump_speed
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
			velocity.y = move_vector.y * jump_speed
		else:
			velocity.y += gravity * delta
	if !can_climb:
		is_climbing = false

func update_animation(move_vector):
	#var move_vector = get_movement_vector()
	if(attacking):
		pass

	# send rpc to server
	elif(Input.is_action_pressed("attack") && !is_climbing && Global.movable):
		attacking = true
		#sprite.play("slash",-1, GameData.weapon_speed[str(Global.player.equipment.rweapon.speed)])
		sprite.play("slash",-1, GameData.weapon_speed[str(Global.player.equipment.rweapon.attackSpeed)])
		#### insert sound play
		determine_weapon_noise()
		"""
		can insert determine_weapon_noise into compositesprite animations
		determine attack speed -> adjust when sound is played (delay for slower wep)
		"""
		Server.send_attack(0)
	else:
		if(!is_on_floor()):
			pass
			sprite.play("jump")

		elif(move_vector.x != 0):
			sprite.play("walk")
	#	elif(tookDamage):
	#		$AnimationPlayer.play("ready")
		else:
			sprite.play("idle")

func determine_weapon_noise() -> void:
	if Global.player.equipment.rweapon.type in ["dagger", "1h_sword", "1h_axe", "staff", "wand"]:
		print("1hsword")
		#var rng = Global.rng.randi_range(1,101)
#		if rng <= 50:
#			pass
#		else:
#			pass
		AudioControl.play_audio("1h_swing")
	elif Global.player.equipment.rweapon.type in ["1h_blunt", "2h_blunt"]:
		AudioControl.play_audio("blunt_swing")
	elif Global.player.equipment.rweapon.type in ["2h_sword", "2h_axe"]:
		AudioControl.play_audio("2h_swing")
	
func movable_switch():
	Global.movable = true
	
func flip_sprite(d):
	for _i in $CompositeSprite.get_children():
		if _i.name != "AnimationPlayer":
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

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		held_down = true
	elif event.is_action_released("ui_down"):
		held_down = false
	elif event.is_action_pressed("attack"):
		if Global.movable:
			return
		else:
			print("cannot attack")


func _on_Button_pressed():
	var temp_pos = self.position
	var temp_input = [0,0,0,1,0]
	recon_arr["input_arr"] = temp_input
	movement_loop(temp_delta, temp_input)
	define_player_state(temp_input)
	#print(temp_pos, " ", self.position)


func _on_Button2_pressed():
	var temp_pos = self.position
	var temp_input = [0,1,0,0,0]
	recon_arr["input_arr"] = temp_input
	movement_loop(temp_delta, temp_input)
	define_player_state(temp_input)
	#print(temp_pos, " ", self.position)
