extends KinematicBody2D

onready var http = $HTTPRequest
onready var http2 = $HTTPRequest2
onready var timer =$Timer
onready var idle_timer =$idle_timer
#contains token and id
var db_info = {}
var cur_position = Vector2.ZERO

# post firestore convert
var email = ""
var characters = []
var characters_info_list = []
var damage = 10
var idle_counter = 0
onready var input_queue = []

var velocity = Vector2.ZERO
var is_climbing = false
var can_climb = false
var attacking = false

var velocity_multiplier = 1
var attack_speed = 1.5
var max_horizontal_speed = null
var jump_speed = null
var gravity = 800
# 0 = right, 1 = left
var direction = 0
var input = [0,0,0,0,0]

#takes int/dex/luck/str values from serverdata.gd
var player_stats

var hittable = true
var current_character
func _physics_process(delta):
	
	if "Map" in str(self.get_path()):
		print(self.position)
		movement_loop(delta)
		#return self.global_position
		
func load_player_stats():
	max_horizontal_speed = current_character.stats.movementSpeed
	jump_speed = current_character.stats.jumpSpeed
	
func attack():
	$AnimationPlayer.play("attack")
func overlapping_bodies():
	if $do_damage.get_overlapping_areas().size() > 0:
		var closest = null
		for body in $do_damage.get_overlapping_areas():
			if closest == null:
				closest = body
			else:
				if pow((closest.position.x - self.position.x), 2) > pow((body.position.x - self.position.x ), 2):
					closest = body
				else:
					pass
		closest.get_parent().npc_hit(damage, self.name)
	else:
		pass

func take_damage(take_damage):
	if hittable:
		hittable = false
		print(self.name + " takes %s damage" % str(take_damage))
		current_character["stats"]["health"] -= take_damage
		print("Current HP: %s" % current_character["stats"]["health"])
		
		# WIP 
		if current_character["stats"]["health"] <= 0:
			print("%s died" % current_character["displayname"])
			Global.player_death(self.name)

		get_node("/root/Server").update_player_stats(self)
		$DamageTimer.start()
	else:
		pass

func experience(experience):
	print(self.name + " gain %s exp" % str(experience))
	var current_exp = current_character["stats"]["experience"]
	var exp_limit = ServerData.experience_table[str(current_character["stats"]["level"])]
	current_exp += experience

	# if level up
	if current_exp >= exp_limit:
		current_exp -= exp_limit
		current_character["stats"]["level"] += 1
		current_character["stats"]["sp"] += 5
		print("%s Level Up" % current_character["displayname"])

		# add ability point skill points
		if current_character["stats"]["class"] != 0:
			current_character["stats"]["ap"] += 3

	current_character["stats"]["experience"] = current_exp
	Global.store_character_data(self.name, current_character["displayname"])
	print("Level: %s" % current_character["stats"]["level"])
	print("EXP: %s" % current_character["stats"]["experience"])
	get_node("/root/Server").update_player_stats(self)

func movement_loop(delta):
	#change_direction()
	var move_vector = get_movement_vector()

	# change get velocity
	get_velocity(move_vector, delta)
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)

	if is_on_floor() or !is_climbing:
		velocity = move_and_slide(velocity, Vector2.UP)
	if is_climbing:
		velocity.x = 0
	#print(self.global_position, " ", self.position)
	return self.global_position

func get_movement_vector():
	var moveVector = Vector2.ZERO
	if !input_queue.empty():
		input = input_queue.pop_front()
	else:
		input = [0,0,0,0,0]
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

func get_velocity(move_vector, delta):
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
			# jump off rope
			elif input[4] == 1 && (input[1] == 1 or input[3] == 1):
				is_climbing = false
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

################################
# edit so direction can be sent through world_state
func change_direction():
	if !input.empty():
		if input[3] == 1 && !attacking:
			if velocity.x < 0 && is_on_floor():
				velocity.x = 0
			direction = 0
		elif input[1] == 1 && !attacking:
			if velocity.x > 0 && is_on_floor():
				velocity.x  = 0
			direction = 1

#####################################################################################################
## not implemented server knockback
##func recieve_knockback(damage_source_pos: Vector2):
##	var knockback_direction = damage_source_pos.direction_to(self.global_position)
##	var knockback = knockback_direction * knockback_modifier *40	
##	self.global_position += knockback


func _on_DamageTimer_timeout():
	hittable = true
	$DamageTimer.stop()

"""
func start_idle_timer():
	$idle_timer.start(1.0)
	print("idle timer start")


# regen 5hp every 5 seconds if idle
func _on_idle_timer_timeout():
	if self.position != cur_position:
		cur_position = self.position
		idle_counter = 0
	else:
		# print("same position")
		if self.is_on_floor():
			idle_counter += 1
			if idle_counter == 5:
				if current_character["stats"]["health"] < current_character["stats"]["maxHealth"]:
					if current_character["stats"]["maxHealth"] - current_character["stats"]["health"] < 5:
						var hp_dif = current_character["stats"]["maxHealth"] - current_character["stats"]["health"]
						current_character["stats"]["health"] += int(hp_dif)
					else:
						print("heal 5 hp")
						current_character["stats"]["health"] += 5
					get_node("/root/Server").update_player_stats(self)
				else:
					pass
				idle_counter = 0
		else:
			idle_counter = 0
"""
