extends Node2D
var map_id = "100001"
var map_name = "Grassy Road 1"

var enemy_id_counter = 0
var enemy_maximum = 2
var first_spawn = Vector2(-559, -143)
var spawn_position = Vector2(-98, -347)

var green_guy = preload("res://scenes/monsterObjects/100001/100001.tscn")
var enemy_types = [green_guy, green_guy]

var enemy_spawn_points = [Vector2(414, -69), Vector2(634, -70)]
var open_locations = [0,1]

var occupied_locations = {}
var enemy_list = {}
var players = []
onready var player_ysort = $YSort/Players
onready var npc_ysort = $YSort/NPC
var counter = 0


func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "SpawnEnemy")
	self.add_child(timer)

func _process(_delta):
	if enemy_list.size() == 0:
		pass
	else:
		for monster_id in enemy_list.keys():
			if enemy_list[monster_id]['EnemyState'] != "Dead":
				var monster_container = get_node("YSort/Monsters/%s" % str(monster_id))
				enemy_list[monster_id]['EnemyLocation'] = monster_container.position
				enemy_list[monster_id]['EnemyHealth'] = monster_container.stats.currentHP
				enemy_list[monster_id]['EnemyState'] = monster_container.state
				enemy_list[monster_id]['Direction'] = monster_container.direction.x
				enemy_list[monster_id]['MissCounter'] = monster_container.miss_counter
				if monster_container.damage_taken.size() > 0:
					counter = 0
					enemy_list[monster_id]['DamageList'] = monster_container.damage_taken.duplicate(true)
					monster_container.damage_taken.clear()
				else:
					if counter < 5:
						counter += 1
					else:
						counter = 0
						enemy_list[monster_id]['DamageList'].clear()
	UpdateItemStateList()
	UpdateProjectileStateList()
	UpdateMonsterList()
	if player_ysort.get_children() != players:
		players = player_ysort.get_children()
	
# after timer function called
func SpawnEnemy():
	# only calculate/spawn monsters when at least 1 player is actively in the map
	if get_node("YSort/Players").get_child_count() == 0:
		pass
	elif enemy_list.size() >= enemy_maximum:
		pass
	else:
		for i in open_locations:
			if i in occupied_locations:
				pass
			else:
				var location = enemy_spawn_points[i]
				occupied_locations[i] = location
				########################################### 
				# spawns server enemy in map
				var new_enemy = enemy_types[i].instance()
				new_enemy.id = new_enemy.name
				new_enemy.map_id = map_id
				new_enemy.position = location
				new_enemy.name = str(i)
				new_enemy.parent = self
				get_node("YSort/Monsters/").add_child(new_enemy, true)
				enemy_list[i] = {'id': new_enemy.id, 'EnemyLocation': location, 'EnemyHealth': new_enemy.stats.currentHP, 'EnemyState': new_enemy.state, 'time_out': 1, "DamageList": [], "MissCounter":  0}
				########################################
				enemy_id_counter += 1

	for enemy in enemy_list.keys():
		if enemy_list[enemy]["EnemyState"] == "Dead":
			if enemy_list[enemy]["time_out"] == 0:
				occupied_locations.erase(enemy)
				get_node("YSort/Monsters/%s" % enemy).queue_free()
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]['time_out'] = enemy_list[enemy]['time_out'] - 1
#	ServerData.monsters[map_id] = enemy_list
#
#	for enemy in enemy_list.keys():
#		if not enemy_list[enemy]["DamageList"].empty():
#			print(enemy_list[enemy]["DamageList"])
#		enemy_list[enemy]["DamageList"] = []
	
func UpdateItemStateList() -> void:
	"""
	gets a list of children nodes in ysort: items -> updates/add item dict
	ServerData.items.keys() are item nodes name. Unique 6 len string of Uppercase Chars and Ints
	"""
	if  get_node("YSort/Items").get_child_count() > 0:
		var _index  = 0
		for item in get_node("YSort/Items").get_children():
			Global.add_item_to_world_state(item, self.name)
			_index += 1

func UpdateProjectileStateList() -> void:
	"""
	gets a list of children nodes in ysort: items -> updates/add item dict
	ServerData.items.keys() are item nodes name. Unique 6 len string of Uppercase Chars and Ints
	"""
	var projectile_list = get_node("YSort/Projectiles").get_children()
	
	Global.remove_projectiles_in_world_state(projectile_list, self.name)
	
	if  projectile_list.size() > 0:
		var _index  = 0
		for projectile in projectile_list:
			Global.add_projectile_to_world_state(projectile, self.name)
			_index += 1

func UpdateMonsterList() -> void:
	ServerData.monsters[map_id] = enemy_list.duplicate(true)
