extends Node2D
var map_id = "100001"
var map_name = "Grassy Road 1"

var enemy_id_counter = 0
var enemy_maximum = 2
var spawn_position = Vector2(113, -247)

var green_guy = preload("res://scenes/monsterObjects/000001/000001.tscn")
var enemy_types = [green_guy, green_guy]

var enemy_spawn_points = [Vector2(414, -69), Vector2(634, -70)]
var open_locations = [0,1]

var occupied_locations = {}
var enemy_list = {}

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
				enemy_list[monster_id]['EnemyHealth'] = monster_container.current_hp
				enemy_list[monster_id]['EnemyState'] = monster_container.state

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
				new_enemy.position = location
				new_enemy.name = str(i)
				get_node("YSort/Monsters/").add_child(new_enemy, true)
				enemy_list[i] = {'id': new_enemy.id,'EnemyName': new_enemy.title, 'EnemyLocation': location, 'EnemyHealth': new_enemy.current_hp, 'EnemyMaxHealth': new_enemy.max_hp, 'EnemyState': new_enemy.state, 'time_out': 1}
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
	ServerData.monsters[map_id] = enemy_list
