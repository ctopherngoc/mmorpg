extends KinematicBody2D

onready var http = $HTTP/HTTPRequest
onready var http2 = $HTTP/HTTPRequest2
onready var timer =$Timers/Timer
onready var idle_timer =$Timers/idle_timer
onready var damage_timer = $Timers/DamageTimer
#contains token and id
var db_info = {}

# post firestore convert
var email = ""
var characters = []
var characters_info_list = []
var idle_counter = 0
onready var input_queue = []
var cur_position = null

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

var hittable = true
var current_character
func _physics_process(delta):
	
	if "Map" in str(self.get_path()):
		movement_loop(delta)

func load_player_stats():
	max_horizontal_speed = current_character.stats.movementSpeed
	jump_speed = current_character.stats.jumpSpeed

func attack(move_id):
	attacking = true
	#basic attack
	if move_id == 0:
		pass
	"""
		# if char.weapon == xxx: 1 hand
			play swing.speed()
			overlapping bodies
			get list of overlapping bodies
			get closest one
			body.do_damage
				return damage
			send server damage
			rpc call all clients to show damage?
			return attack call
		
		# elif char.weapon = xxx: large
			play swing.speed ()
		
		# else ranged weapon:
			if has ammo
				play.shoot()
			else:
				return no ammo
		
	"""
	#$AnimationPlayer.play("attack")
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
		####################################################			
		do_damage()
		#closest.get_parent().npc_hit(damage, self.name)
		#####################################################
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
		damage_timer.start()
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
					Global.send_climb_data(self.name, 1)
			# jump off rope
			elif input[4] == 1 && (input[1] == 1 or input[3] == 1):
				is_climbing = false
				Global.send_climb_data(self.name, 1)
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
					Global.send_climb_data(self.name, 2)
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
		Global.send_climb_data(self.name, 0)

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
	damage_timer.stop()

func start_idle_timer():
	idle_timer.start(1.0)
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
			
func do_damage():
	print("mob hit")

func _on_Timer_timeout():
	pass # Replace with function body.

func overlappingBodies():
	print("area ovlapping: " + str($do_damage.get_overlapping_areas().size()))
	for body in $do_damage.get_overlapping_areas():
		print('player overlapping with: ', body)
