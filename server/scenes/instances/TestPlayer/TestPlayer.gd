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
var hittable = true
var current_character = {
	"displayname": "testing123",
	
	"equipment": {
		"rweapon": {
			"owner": "testing123",
			"id": 100000,
			"uniqueID":14333321,
			"job": 0,
			"type": "1h_sword",
			"name": "temp sword",
			"speed": 5,
			"slot": 7,
			"attack": 15,
			"magic": 0,
			"maxHealth": 0,
			"maxMana": 0,
			"strength": 5,
			"wisdom": 5,
			"dexterity": 5,
			"luck": 5,
			"movementSpeed": 0,
			"jumpSpeed": 0,
			"avoidability": 0,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 0,
			"bossPercent": 0,
			"damagePercent": 0,
			"critRate": 0,
			},# rwep
		#"lweapon": null,
	},#equip
	"stats": 
	{
		"base": {
			"maxRange": 50,
			"minRange": 0,
			"health": 50,
			"mana": 50,
			"maxHealth": 50,
			"maxMana": 50,
			"level": 1,
			"experience": 0,
			"class": 0,
			"job": 0,
			"sp": 0,
			"ap": 0,
			"strength": 4,
			"wisdom": 4,
			"dexterity": 4,
			"luck": 4,
			"movementSpeed": 100,
			"jumpSpeed": 200,
			"avoidability": 4,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 10,
			"bossPercent": 1,
			"damagePercent": 1,
			"critRate": 5,
		},
		"equipment": {
			"attack": 0,
			"magic": 0,
			"maxHealth": 0,
			"maxMana": 0,
			"strength": 0,
			"wisdom": 0,
			"dexterity": 0,
			"luck": 0,
			"movementSpeed": 0,
			"jumpSpeed": 0,
			"avoidability": 0,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 0,
			"bossPercent": 0,
			"damagePercent": 0,
			"critRate": 0,
		},
	},
	"inventory":
		{"100000":0,
		"equipment": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null],
			"etc": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null],
			"use": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]}, #inventory
}
var attacking = false
var mobs_hit = []

func _ready():
	#ServerData.characters_data[str(self.name)] = current_character
	#self.name = "100000"
	pass
	
func attack(move_id):
	attacking = true
	#basic attack
	if move_id == 0:
		var equipment = current_character.equipment
		if equipment.rweapon.type == "1h_sword":
			animation.play("1h_sword",-1, ServerData.static_data.weapon_speed[equipment.rweapon.speed])
			yield(animation, "animation_finished")
		elif equipment.rweapon.type == "2h_sword":
			pass
		elif equipment.weapon.type == "bow":
		# else ranged weapon:
			if equipment.ammo.amount > 0:
				animation.play("bow",-1, ServerData.static_data.weapon_speed[equipment.rweapon.speed])
			else:
				return "not enough ammo"
		#var mob_list = overlapping_bodies()
		
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
						get_parent().npc_hit(damage, self.name)
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
				mob_parent.npc_hit(damage, self.name)

func overlapping_bodies():
	#if $attack_range.get_overlapping_areas().size() > 0:
	mobs_hit.clear()
	# multi hit based on class currently
	for body in $attack_range.get_overlapping_areas():
		print(body.get_parent())
		mobs_hit.append(body)

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
	var exp_limit = ServerData.static_data.experience_table[str(current_character["stats"]["level"])]
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

func _on_DamageTimer_timeout():
	hittable = true
	damage_timer.stop()

func start_idle_timer():
	idle_timer.start(1.0)
	print("idle timer start")

func do_damage():
	print("mob hit")

func _on_Timer_timeout():
	pass # Replace with function body.

func loot_request():
	print(self.name, " ", "Pressed Loot")
	var loot_list = loot_node.get_overlapping_areas()
	Global.lootRequest(self, loot_list)
