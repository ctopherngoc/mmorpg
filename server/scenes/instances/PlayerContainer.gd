extends KinematicBody2D

onready var http = $HTTP/HTTPRequest
onready var http2 = $HTTP/HTTPRequest2
onready var timer =$Timers/Timer
onready var idle_timer =$Timers/idle_timer
onready var damage_timer = $Timers/DamageTimer
onready var animation = $AnimationPlayer
onready var loot_node = $loot_box
#contains token and id
var db_info = {}
onready var loggedin = true

# post firestore convert
# possible hashmap or references
###############
var email = ""
var characters = []
var characters_info_list = []
var current_character
#################

var mobs_hit = []
var idle_counter = 0
onready var input_queue = []
var cur_position = null
var velocity = Vector2.ZERO

# change to one variable
var is_climbing = false
var can_climb = false

var velocity_multiplier = 1
var max_horizontal_speed = null
var jump_speed = null
var gravity = 800

# 0 = right, 1 = left
var direction = 0
var input = [0,0,0,0,0,0]
var attacking = false
var hittable = true

# sprite string to put in ws
onready var sprite = []

#implement animation again
"""
f: is on floor: 0:no 1: yes
d: direction 0:L 1:R
a: attack 0 not 1 is
"""
onready var animation_state = {
	"f": 1,
	"d": 1,
	"a": 0,
}

########
#temp
onready var recon_arr = {
	"input_arr": [],
	"velocity": Vector2(0,0),
	"mns": null,
	"end_pos": Vector2(0,0),
	"m_vector": null,
}
########

func _physics_process(delta: float) -> void:
	if loggedin:
		if "Map" in str(self.get_path()):
			movement_loop(delta)
	if animation_state.a:
		print("attacking")

func get_animation() -> Dictionary:
	if self.is_on_floor():
		animation_state.f = 1
	else:
		animation_state.f = 0
	animation_state.d = direction
	if attacking:
		animation_state.a = 1
	else:
		animation_state.a = 0
	return animation_state

func load_player_stats() -> void:
	max_horizontal_speed = current_character.stats.base.movementSpeed
	jump_speed = current_character.stats.base.jumpSpeed
	print(typeof(current_character.inventory["100000"]))

func attack(move_id: int) -> void:
	attacking = true
	
	#basic attack
	if move_id == 0:
		var equipment = current_character.equipment
		if equipment.rweapon.type == "1h_sword":
			animation.play("1h_sword",-1, ServerData.static_data.weapon_speed[equipment.rweapon.attackSpeed])
			yield(animation, "animation_finished")
		elif equipment.rweapon.type == "2h_sword":
			pass
		elif equipment.weapon.type == "bow":
		# else ranged weapon:
			if equipment.ammo.amount > 0:
				animation.play("bow",-1, ServerData.static_data.weapon_speed[equipment.rweapon.attackSspeed])
			else:
				return "not enough ammo"
		# no mobs overlap
		if mobs_hit.size() == 0:
			print("no mobs hit")
		# there are mobs overlap
		else:
			# physical mobbing auto attack class
			if current_character.stats.base.class == 10:
				if mobs_hit.size() < 6:
					for mob in mobs_hit:
						var mob_parent = mob.get_parent()
						var damage = Global.damage_formula(1, current_character, mob_parent.stats)
						Global.npc_hit(damage, mob_parent, self.name)
			# singe mob physical basic attack
			else:
				var closest = null
				for monster in mobs_hit:
					if closest == null:
						closest = monster
					else:
						if pow((monster.position.x - self.position.x), 2) > pow((monster.position.x - self.position.x ), 2):
							closest = monster
				var mob_parent = closest.get_parent()
				var damage = Global.damage_formula(1, current_character, mob_parent.stats)
				#mob_parent.npc_hit(damage, self.name)
				Global.npc_hit(damage, mob_parent, self.name)
	attacking = false

func overlapping_bodies() -> void:
	#if $attack_range.get_overlapping_areas().size() > 0:
	mobs_hit.clear()
	# multi hit based on class currently
	for body in $attack_range.get_overlapping_areas():
		print(body.get_parent())
		mobs_hit.append(body)

func take_damage(take_damage: int) -> void:
	if hittable:
		hittable = false
		print(self.name + " takes %s damage" % str(take_damage))
		current_character.stats.base.health -= take_damage
		print("Current HP: %s" % current_character.stats.base.health)
		
		# WIP 
		if current_character.stats.base.health <= 0:
			print("%s died" % current_character.displayname)
			Global.player_death(self.name)

		get_node("/root/Server").update_player_stats(self)
		damage_timer.start()
	else:
		pass

func experience(experience: int) -> void:
	print(self.name + " gain %s exp" % str(experience))
	var current_exp = current_character.stats.base.experience
	var exp_limit = ServerData.static_data.experience_table[str(current_character.stats.base.level)]
	current_exp += experience

	# if level up
	if current_exp >= exp_limit:
		# multiple levels
		while current_exp >= exp_limit:
			print("current xp: %s, exp max: %s, ending xp: %s" % [current_exp, exp_limit,  current_exp - exp_limit])
			current_exp %= exp_limit
			print("new current xp: %s" % current_exp)
			current_character.stats.base.level += 1
			current_character.stats.base.sp += 5
			print("%s Level Up" % current_character.displayname)
			
			# add ability point skill points
			if current_character.stats.base.class != 0:
				current_character.stats.base.ap += 3
			# update exp_limit for multiple levels
			get_node("/root/Server").update_player_stats(self)
			exp_limit = ServerData.static_data.experience_table[str(current_character.stats.base.level)]
	current_character.stats.base.experience = current_exp
	get_node("/root/Server").update_player_stats(self)
	Global.store_character_data(self.name, current_character.displayname)
	print("Level: %s" % current_character.stats.base.level)
	print("EXP: %s" % current_character.stats.base.experience)

func movement_loop(delta: float) -> void:
	var move_vector = get_movement_vector()
	recon_arr["m_vector"] = move_vector
	change_direction()
	# change get velocity
	get_velocity(move_vector, delta)
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
	#if recon_arr["input_arr"] != [0,0,0,0,0] and recon_arr["input_arr"] != []:
		#print(recon_arr)
	#return self.global_position

func get_movement_vector() -> Vector2:
	var moveVector = Vector2.ZERO
	if !input_queue.empty():
		input = input_queue.pop_front()
	else:
		# [up, down, left, right, jump, loot]
		input = [0,0,0,0,0,0]
	if input[5]:
		self.loot_request()
	recon_arr["input_arr"] = input
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

func get_velocity(move_vector: Vector2, delta: float) -> void:
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
					Global.send_climb_data(int(self.name), 1)
			# jump off rope
			elif input[4] == 1 && (input[1] == 1 or input[3] == 1):
				is_climbing = false
				Global.send_climb_data(int(self.name), 1)
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
					Global.send_climb_data(int(self.name), 2)
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
		Global.send_climb_data(int(self.name), 0)

################################
# edit so direction can be sent through world_state
func change_direction() -> void:
	if !input.empty():
		if input[3] == 1 && !attacking:
			if velocity.x < 0 && is_on_floor():
				velocity.x = 0
			if direction == 1:
				direction = 0
				self.set_scale(Vector2(1,1))
				self.set_rotation(0.0)
		elif input[1] == 1 && !attacking:
			if velocity.x > 0 && is_on_floor():
				velocity.x  = 0
			if direction == 0:
				direction = 1
				self.set_scale(Vector2(-1,1))
				self.set_rotation(0.0)

#####################################################################################################
## not implemented server knockback
##func recieve_knockback(damage_source_pos: Vector2):
##	var knockback_direction = damage_source_pos.direction_to(self.global_position)
##	var knockback = knockback_direction * knockback_modifier *40	
##	self.global_position += knockback

func _on_DamageTimer_timeout() -> void:
	hittable = true
	damage_timer.stop()

func start_idle_timer() -> void:
	idle_timer.start(1.0)
	print("idle timer start")

# regen 5hp every 5 seconds if idle
func _on_idle_timer_timeout() -> void:
	if self.position != cur_position or attacking or is_climbing:
		cur_position = self.position
		idle_counter = 0
	else:
		# print("same position")
		if self.is_on_floor():
			idle_counter += 1
			if idle_counter == 5:
				if current_character.stats.base.health < current_character.stats.base.maxHealth:
					if current_character.stats.base.maxHealth - current_character.stats.base.health < 5:
						var hp_dif = current_character.stats.base.maxHealth - current_character.stats.base.health
						current_character.stats.base.health += int(hp_dif)
					else:
						#print("heal 5 hp")
						current_character.stats.base.health += 5
					get_node("/root/Server").update_player_stats(self)
				else:
					pass
				idle_counter = 0
		else:
			idle_counter = 0
			
func do_damage() -> void:
	print("mob hit")

func _on_Timer_timeout() -> void:
	pass # Replace with function body.

func loot_request() -> void:
	#print(self.name, " ", "Pressed Loot")
	var loot_list = loot_node.get_overlapping_areas()
	Global.lootRequest(self, loot_list)

func update_sprite_array():
	var temp_dict = current_character.avatar
	sprite[0] = str(temp_dict.bcolor) + str(temp_dict.body)
	sprite[1] = str(temp_dict.brow)
	sprite[2] = str(temp_dict.bcolor) + str(temp_dict.ear)
	#sprite[3] = temp_dict.bcolor + temp_dict.ear
	sprite[3] = str(temp_dict.ecolor) + str(temp_dict.eye)
	sprite[4] = str(temp_dict.hcolor) + str(temp_dict.hair)
	sprite[5] = str(temp_dict.head)
	sprite[6] = str(temp_dict.mouth)

	temp_dict = current_character.equipment
	sprite[7] = str(temp_dict.headgear)
	sprite[8] = str(temp_dict.top)
	sprite[9] = str(temp_dict.bottom)
	sprite[10] = str(temp_dict.rweapon.id)
	sprite[11] = str(temp_dict.lweapon)
	sprite[12] = str(temp_dict.eyeacc)
	sprite[13] = str(temp_dict.earring)
	sprite[14] = str(temp_dict.faceacc)
	sprite[15] = str(temp_dict.glove)
	sprite[16] = str(temp_dict.tattoo)
	
