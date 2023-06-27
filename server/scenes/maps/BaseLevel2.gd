extends Node2D
var mapName = "BaseLevel2"
var enemy_id_counter = 0
var enemy_maximum = 2
#var portal = {
#	'Portal1' : Vector2(103, -290),
#	'Portal2' : Vector2(904, -525),
#}

############################################
# maybe create a list of dictionary map of how many monsters and their spawn location in the map in relation to open_location
# not used
var greenGuy = preload("res://scenes/monsters/GreenGuy.tscn")
var enemy_types = ["Green Guy"]
############################################

var enemy_spawn_points = [Vector2(414, -69), Vector2(634, -70)]

# only used for rng spawning
var open_locations = [0,1]

var occupied_locations = {}
var enemy_list = {}

func _ready():
#	var timer = Timer.new()
#	timer.wait_time = 3
#	timer.autostart = true
#	timer.connect("timeout", self, "SpawnEnemy")
#	self.add_child(timer)
	pass

func _process(_delta):
	pass
#	if enemy_list.size() == 0:
#		pass
#	else:
#		for monster_id in enemy_list.keys():
#			if enemy_list[monster_id]['EnemyState'] != "Dead":
#				var monster_container = get_node("YSort/Monsters/%s" % str(monster_id))
#				enemy_list[monster_id]['EnemyLocation'] = monster_container.global_position
#				enemy_list[monster_id]['EnemyHealth'] = monster_container.current_hp
#				enemy_list[monster_id]['EnemyState'] = monster_container.state
#			#else:
#				#open_locations.append(occupied_locations[monster_id])
#				#occupied_locations.erase(monster_id)

# after timer function called
func SpawnEnemy():
	# only calculate/spawn monsters when at least 1 player is actively in the map
	if get_node("/root/Server/World/Maps/BaseLevel/YSort/Players").get_child_count() == 0:
		pass
	elif enemy_list.size() >= enemy_maximum:
		pass
	else:
		#print(" start open locations: ", open_locations)
		for i in open_locations:
			#print(i, occupied_locations)
			#print(occupied_locations)
			if i in occupied_locations:
				pass
			else:
				var location = enemy_spawn_points[i]
				#occupied_locations[i] = location
				occupied_locations[i] = location
				########################################### 
				# spawns server enemy in map
				var new_enemy = greenGuy.instance()
				new_enemy.position = location
				new_enemy.name = str(i)
				get_node("YSort/Monsters/").add_child(new_enemy, true)
				enemy_list[i] = {'EnemyName': new_enemy.title, 'EnemyLocation': new_enemy.location, 'EnemyHealth': new_enemy.current_hp, 'EnemyMaxHealth': new_enemy.max_hp, 'EnemyState': new_enemy.state, 'time_out': 1}
				########################################
				enemy_id_counter += 1
				#open_locations.erase(i)
				
		#print("end")
				
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["EnemyState"] == "Dead":
			if enemy_list[enemy]["time_out"] == 0:
				#open_locations.append(occupied_locations[enemy])
				occupied_locations.erase(enemy)
				get_node("YSort/Monsters/%s" % enemy).queue_free()
				# open_locations.append(int(enemy))
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]['time_out'] = enemy_list[enemy]['time_out'] - 1
	ServerData.monsters[mapName] = enemy_list
