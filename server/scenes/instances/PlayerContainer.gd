extends KinematicBody2D

onready var attack_timer = $Timers/AttackTimer
onready var idle_timer = $Timers/IdleTimer
onready var damage_timer = $Timers/DamageTimer
onready var logging_timer = $Timers/LoggingTimer
#onready var animation = $AnimationPlayer
onready var loot_node = $loot_box
onready var loot_timer = $Timers/LootTimer
onready var CDTimer = $Timers/CDTimer
onready var BuffTimer = $Timers/BuffTimer
onready var attack_range = $attack_range
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
onready var cooldowns: Dictionary = {}
onready var buffs: Dictionary = {}
#################

var mobs_hit = []
var idle_counter = 0
onready var input_queue = []
var cur_position = null
var velocity = Vector2.ZERO

# change to one variable
var is_climbing = false
var can_climb = false

var vertical_speed: int
var horizontal_speed: int
var gravity = 800

# 1 = right, -1 = left
var direction = 1
var input = [0,0,0,0,0,0]
var attacking = false
var hittable = true
var looting = false

# sprite string to put in ws
onready var sprite = []

#implement animation again
"""
f: is on floor: 0:no 1: yes
d: direction 0:L 1:R
a: attack key {
	0 = idle
	1 = basic attack
	3 = ready
}
"""
onready var animation_state = {
	"c": 0,
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

onready var equip_array = ["headgear", "top", "bottom", "rweapon", "lweapon", "eyeacc", "earring", "faceacc", "glove", "tattoo"]
########

func _physics_process(delta: float) -> void:
	if loggedin:
		if "Map" in str(self.get_path()):
			if not attacking:
				animation_state.a = 0
				
			movement_loop(delta)
			if not cooldowns.empty() and CDTimer.is_stopped():
				CDTimer.start()
			if not buffs.empty() and BuffTimer.is_stopped():
				BuffTimer.start()

func get_animation() -> Dictionary:
	if self.is_on_floor():
		animation_state.f = 1
	else:
		animation_state.f = 0
	animation_state.d = direction
	if not attacking:
		animation_state.a = 0
	return animation_state

func load_player_stats() -> void:
	get_directional_speed()

func normal_attack() -> void:
#	attacking = true
#	animation_state["a"] = 1
	#basic attack
	var equipment = current_character.equipment
	overlapping_bodies()
#	elif equipment.weapon.type == "bow":
#	# else ranged weapon:
#		if equipment.ammo.amount > 0:
#			animation.play("bow",-1, ServerData.static_data.weapon_speed[equipment.rweapon.attackSspeed])
#		else:
#			return "not enough ammo"
	# no mobs overlap
	if mobs_hit.size() == 0:
		print("no mobs hit")
	# there are mobs overlap
	else:
		# physical mobbing auto attack class
		if current_character.stats.base.job == 10:
			if mobs_hit.size() < 6:
				for mob in mobs_hit:
					var mob_parent = mob.get_parent()
					var damage_list = Global.damage_formula(1, current_character, mob_parent.stats)
					Global.npc_hit(damage_list, mob_parent, self)
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
			var damage_list = Global.damage_formula(1, current_character, mob_parent.stats)
			print(damage_list)
			#mob_parent.npc_hit(damage, self.name)
			Global.npc_hit(damage_list, mob_parent, self)

func skill(skill_data: Dictionary, skill_level: int) -> void:
	attacking = true
	if skill_data.type == "attack":
		if not skill_data["weaponType"] or current_character.equipment.rweapon.weaponType in skill_data["weaponType"]:
			animation_state["a"] = skill_data.animation
			
			if skill_data.attackType == "projectile":
				attack_timer.wait_time = 1.0 / ServerData.weapon_speed[current_character.equipment.rweapon.attackSpeed]
				attack_timer.start()
				return
			else:
				var equipment = current_character.equipment
				overlapping_bodies()
				
				if mobs_hit.size() == 0:
					print("no mobs hit")
				# there are mobs overlap
				else:
					# physical mobbing auto attack class
					if skill_data.targetCount[skill_level] > 1:
						if mobs_hit.size() < skill_data.targetCount[skill_level]:
							for mob in mobs_hit:
								var mob_parent = mob.get_parent()
								var damage_array = Global.damage_formula(skill_data["damangeType"], current_character, mob_parent.stats, skill_data.hitAmount[skill_level], skill_data.damagePercent[skill_level])
								Global.npc_hit(damage_array, mob_parent, self)
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
						var damage_array = Global.damage_formula(1, current_character, mob_parent.stats)
						#mob_parent.npc_hit(damage, self.name)
						Global.npc_hit(damage_array, mob_parent, self)
	else:
		# buff, heal, projectile
		animation_state["a"] = skill_data.animation
		attack_timer.wait_time = 1.0 / ServerData.weapon_speed[current_character.equipment.rweapon.attackSpeed]
		attack_timer.start()

func overlapping_bodies() -> void:
	#if $attack_range.get_overlapping_areas().size() > 0:
	mobs_hit.clear()
	# multi hit based on class currently
	print("starting mob hit")
	for body in $attack_range.get_overlapping_areas():
		print(body)
		#print(body.get_parent())
		mobs_hit.append(body)

func take_damage(take_damage: int) -> void:
	if hittable:
		hittable = false
		#print(self.name + " takes %s damage" % str(take_damage))
		current_character.stats.base.health -= take_damage
		#print("Current HP: %s" % current_character.stats.base.health)
		
		# WIP 
		if current_character.stats.base.health <= 0:
			print("%s died" % current_character.displayname)
			Global.player_death(self.name)

		get_node("/root/Server").update_player_stats(self)
		damage_timer.start()
	else:
		pass

func experience(experience: int) -> void:
	#print(self.name + " gain %s exp" % str(experience))
	var current_exp = current_character.stats.base.experience
	var exp_limit = ServerData.static_data.experience_table[str(current_character.stats.base.level)]
	current_exp += experience

	# if level up
	if current_exp >= exp_limit:
		# multiple levels
		while current_exp >= exp_limit:
			current_exp %= exp_limit
			#("new current xp: %s" % current_exp)
			current_character.stats.base.level += 1
			current_character.stats.base.sp += 5
			
			# insert hp increase here
			var new_hp = int(round(Global.rng.randi_range(ServerData.static_data.job_dict[current_character.stats.base.job].HealthMin, ServerData.static_data.job_dict[current_character.stats.base.job].HealthMax)))
			if current_character.stats.base.job in [9999999]:
				# look up skill level add more hp based on skill level
				pass
			# set new health -> set health to max
			current_character.stats.base.maxHealth += new_hp
			current_character.stats.base.health = current_character.stats.base.maxHealth
			# insert mp increase here
			var new_mana = int(round( 20 + (current_character.stats.base.wisdom * 0.4)))
			if current_character.stats.base.job in [888888888]:
				# look up skill level add more mp based on skill level
				pass
			# set new maxmp -> set mana to max
			current_character.stats.base.maxMana += new_mana
			current_character.stats.base.mana = current_character.stats.base.maxMana
			# heal to full hp and mp
			
			# add ability point skill points
			####################################################################################
			if current_character.stats.base.level <= 10:
				current_character.stats.base.ap[0] += 1
			elif current_character.stats.base.level > 10 and current_character.stats.base.level <= 30:
				current_character.stats.base.ap[1] += 3
			elif current_character.stats.base.level > 30 and current_character.stats.base.level <= 70:
				current_character.stats.base.ap[2] += 3
			elif current_character.stats.base.level > 70 and current_character.stats.base.level <= 120:
				current_character.stats.base.ap[3] += 3
			else:
				current_character.stats.base.ap[4] += 3
			#####################################################################################
			# update exp_limit for multiple levels
			get_node("/root/Server").update_player_stats(self)
			exp_limit = ServerData.static_data.experience_table[str(current_character.stats.base.level)]
	current_character.stats.base.experience = current_exp
	get_node("/root/Server").update_player_stats(self)
	Global.store_character_data(self.name, current_character.displayname)

func movement_loop(delta: float) -> void:
	get_directional_speed()
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
		animation_state["c"] = 1
		velocity.x = 0
	else:
		animation_state["c"] = 0

func get_movement_vector() -> Vector2:
	var moveVector = Vector2.ZERO
	if !input_queue.empty():
		input = input_queue.pop_front()
	else:
		# [up, down, left, right, jump, loot]
		input = [0,0,0,0,0,0]
	if input[5]:
		if not looting:
			self.loot_request()
	recon_arr["input_arr"] = input
	# calculating x vector, allow x-axis jump off ropes or idle on floor
	if (!attacking && is_on_floor()) or (input[1] == 1 or input[3] == 1) and input[4] == 1:
		moveVector.x = (input[3] - input[1])
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
				velocity.y = move_vector.y * vertical_speed
				velocity.x = move_vector.x * 200
		# can climb but not climbing
		else:
			#if moving
			if (move_vector.y < 0 && is_on_floor()):
				velocity.y = move_vector.y * vertical_speed
			# press up on ladder initiates climbing
			elif input[0] == 1 or input[2] == 1:
				is_climbing = true
				Global.send_climb_data(int(self.name), 2)
				velocity.y = 0
				velocity.x = 0
				if input[2] == 1:
					#self.set_collision_layer_bit(1, false)
					self.position.y += 1
					#self.set_collision_layer_bit(1, true)
			# over lapping ladder pressing nothing allows gravity
			else:
				velocity.y += gravity * delta
	# not climbable state
	else:
		if is_climbing:
			is_climbing = false
			Global.send_climb_data(int(self.name), 0)
		# normal movement
		if (move_vector.y < 0 && is_on_floor()):
			velocity.y = move_vector.y * vertical_speed
		else:
			velocity.y += gravity * delta
		

################################
# edit so direction can be sent through world_state
func change_direction() -> void:
	if !input.empty():
		if input[3] == 1 && !attacking:
			if velocity.x < 0 && is_on_floor():
				velocity.x = 0
			#if left -> right
			if direction == -1:
				direction = 1
				self.set_scale(Vector2(1,1))
				self.set_rotation(0.0)
		elif input[1] == 1 && !attacking:
			if velocity.x > 0 && is_on_floor():
				velocity.x  = 0
			# if right -> left
			if direction == 1:
				direction = -1
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

func loot_request() -> void:
	#print(self.name, " ", "Pressed Loot")
	looting = true
	var loot_list = loot_node.get_overlapping_areas()
	Global.lootRequest(self, loot_list)

func update_sprite_array():
	var temp_dict = current_character.avatar
	sprite[0] = str(temp_dict.bcolor) + str(temp_dict.body)
	sprite[1] = str(temp_dict.brow)
	sprite[2] = str(temp_dict.bcolor) + str(temp_dict.ear)
	sprite[3] = str(temp_dict.ecolor) + str(temp_dict.eye)
	sprite[4] = str(temp_dict.hcolor) + str(temp_dict.hair)
	sprite[5] = str(temp_dict.head)
	sprite[6] = str(temp_dict.mouth)

	var x = 7
	temp_dict = current_character.equipment
	
	for i in equip_array:
		if temp_dict[i]:
			sprite[x] = temp_dict[i].id
		else:
			sprite[x] = null
		x += 1
		
func _on_loot_timer_timeout():
	looting = false

func _on_CDTimer_timeout():
	if not cooldowns.empty():
		var skills = cooldowns.keys()
		for skill in skills:
			if cooldowns[skill] == 1:
# warning-ignore:return_value_discarded
				cooldowns.erase(skill)
			else:
				cooldowns[skill] -= 1
	else:
		CDTimer.stop()

func _on_BuffTimer_timeout():
	if not buffs.empty():
		var buff_list = buffs.keys()
		for buff in buff_list:
			if buffs[buff] == 1:
# warning-ignore:return_value_discarded
				buffs.erase(buff)
				Global.cancel_buff(self, buff)
			else:
				buffs[buff] -= 1
	else:
		BuffTimer.stop()

func get_directional_speed() -> void:
	vertical_speed = current_character.stats.base.jumpSpeed + current_character.stats.equipment.jumpSpeed + current_character.stats.buff.jumpSpeed
	horizontal_speed = current_character.stats.base.movementSpeed + current_character.stats.equipment.movementSpeed + current_character.stats.buff.movementSpeed


func _on_AttackTimer_timeout():
	print("%s animation finish" % self.name)
	attacking = false
