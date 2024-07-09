######################################################################
# Client Global Singleton that controls the backend of the client system.
# Takes server state from Server Singleton to update client world
# controls spawning monsters, players, server reconsiliation
# contains data for: current map, in_game, last/current map/portal, player position, player container
######################################################################

extends Node
onready var version: String = "4.1.0"
onready var local: bool = false
onready var ip: String
onready var input_queue: Array = []
onready var interpolation_offset: int = 200
onready var current_map: String = ""
onready var in_game = false
onready var floating_text = preload("res://scenes/userInerface/FloatingText.tscn")
onready var projectile = preload("res://scenes/skillObjects/Projectile.tscn")
onready var last_recon
onready var login_timer = $Timer

var player_template = preload("res://scenes/playerObjects/OtherPlayerSprite.tscn")
var player_node
var last_world_state: int = 0
var world_state_buffer: Array = []
var ui = null
var movable: bool = true
var rng = RandomNumberGenerator.new()

var character_list: Array = []
var player = null
var last_portal = null
var last_map = null
var player_position = null

var default_keybind = {
	'shift': null, 'ins': null, 'home': null, 'pgup': null, 'ctrl': "attack",  'del': null, 'end': null, 'pgdn': null,
	'`': null, '1': null, '2': null, '3': null, '4': null, '5': null, '6': null, '7': null, '8': null, '9': null, '0': null, '-': null, '=': null,
	 'f1': null, 'f2': null, 'f3': null, 'f4': null, 'f5': null, 'f6': null, 'f7': null, 'f8': null, 'f9': null, 'f10': null, 'f11': null, 'f12': null,
	'q': null, 'w': null, 'e': null, 'r': null, 't': null, 'y': null, 'u': null, 'i': 'inventory', 'o': null, 'p': null, '[': null, ']': null,
	'a': null, 's': "stat", 'd': null, 'f': null, 'g': null, 'h': null, 'j': null, 'k': 'skill', 'l': null, ';': null, "'": null,
	'z': 'loot', 'x': null, 'c': null, 'v': null, 'b': null, 'n': null, 'm': null, ',': null, '.': null, '/': null,
	}

# loads player info
func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("log_out", self, "log_out")

func update_lastmap(map: String) -> void:
	last_map = map
	
func change_background() -> void:
	VisualServer.set_default_clear_color(Color(0.4,0.4,0.4,1.0))
		
func update_world_state(world_state: Dictionary) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta: float) -> void:
# warning-ignore:unused_variable
	# Current turn off client process of other characters and enemy because
	# working on item drop, data load from json/spreadsheet etc
	if in_game and !Server.testing:
		interpolation_offset = OS.get_system_time_msecs() - Server.client_clock
		#print(OS.get_system_time_msecs(), " ", Server.client_clock, " ", OS.get_system_time_msecs() - Server.client_clock)
		var render_time = OS.get_system_time_msecs() - interpolation_offset
		#var render_time = Server.client_clock
		if world_state_buffer.size() > 1 && Server.server_status:
			while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
				world_state_buffer.remove(0)
			# has future state
			if world_state_buffer.size() > 2:
				despawn_players(world_state_buffer[2]["P"].keys())
				var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[0]["T"])
				if current_map != world_state_buffer[2]["ID"]:
					return
				for player_state in world_state_buffer[2]["P"].keys():
					#print(world_state_buffer[2]["P"][player_state]["S"])
					if player_state == get_tree().get_network_unique_id():
						continue
					if not world_state_buffer[1]["P"].has(player_state):
						continue
					if world_state_buffer[1]["P"][player_state]["M"] == Global.current_map:
						if get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_state)):
							var player_container = get_node("/root/GameWorld/MapNode/%s/OtherPlayers/" %Global.current_map + str(player_state))
							player_container.update_sprite(world_state_buffer[2]["P"][player_state]["S"])
							var new_position = lerp(world_state_buffer[1]["P"][player_state]["P"], world_state_buffer[2]["P"][player_state]["P"], interpolation_factor)
							var animation = world_state_buffer[2]["P"][player_state]["A"]
							player_container.move_player(new_position, animation)
							if world_state_buffer[2]["P"][player_state]["S"] != player_container.sprite:
								var new_sprite = world_state_buffer[2]["P"][player_state]["S"]
								player_container.update_sprite(new_sprite)
						# check if character map == client map
						else:
							spawn_new_player(player_state, world_state_buffer[2]["P"][player_state])
					# probably not used after chunking
					else:
						if get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_state)):
							print("Global Stop 1")
							#despawn_player(player_state)
				# map keys can be empty
				if world_state_buffer[2]["E"].size() > 0:
					#spawn monsters function
					for monster in world_state_buffer[2]["E"].keys():
						if not world_state_buffer[1]["E"].has(monster):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Monsters" % Global.current_map).has_node(str(monster)):
							var monster_node = get_node("/root/GameWorld/MapNode/%s/Monsters/" % Global.current_map + str(monster))
							# monster dead on server
							if world_state_buffer[1]["E"][monster]["EnemyHealth"] < monster_node.current_hp:
								monster_node.damage_taken(world_state_buffer[1]["E"][monster]["EnemyHealth"], world_state_buffer[1]["E"][monster]["DamageList"])
							else:
								if world_state_buffer[1]["E"][monster]["MissCounter"] > monster_node.miss_counter:
									monster_node.miss_counter += 1
									monster_node.damage_taken(world_state_buffer[1]["E"][monster]["EnemyHealth"], world_state_buffer[1]["E"][monster]["DamageList"])

							if world_state_buffer[2]["E"][monster]["EnemyHealth"] <= 0:
								if monster_node.despawn != 0:
									print("Global Stop 2")
									monster_node.on_death()
							else:
								var new_position = lerp(world_state_buffer[1]["E"][monster]["EnemyLocation"], world_state_buffer[2]["E"][monster]["EnemyLocation"], interpolation_factor)
								monster_node.move(new_position, world_state_buffer[2]["E"][monster]["EnemyState"], world_state_buffer[2]["E"][monster]["Direction"])
						else:
							# if actually alive respawned monster
							if world_state_buffer[2]["E"][monster]['time_out'] != 0 && world_state_buffer[2]["E"][monster]['EnemyState'] != "Dead":
								spawn_monster(monster, world_state_buffer[2]["E"][monster])
							
				#################################################################
				if world_state_buffer[2]["I"].size() > 0:
					var current_item_nodes = get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).get_children()
					# remove items if current state has item but future does not have it
					for item in current_item_nodes:
						if not item.name in world_state_buffer[2]["I"].keys():
							item.queue_free()
					for item in world_state_buffer[2]["I"].keys():
						if not world_state_buffer[1]["I"].has(item):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).has_node(str(item)):
							# floor both world state item locations 
							var ws1 = Vector2(floor(world_state_buffer[1]["I"][item]["P"].x), floor(world_state_buffer[1]["I"][item]["P"].y))
							var ws2 = Vector2(floor(world_state_buffer[2]["I"][item]["P"].x), floor(world_state_buffer[2]["I"][item]["P"].y))
							# if they are equal dont update the location
							if ws1 != ws2:
								var item_node = get_node("/root/GameWorld/MapNode/%s/Items/" % Global.current_map + str(item))
								
								var new_position = lerp(world_state_buffer[1]["I"][item]["P"], world_state_buffer[2]["I"][item]["P"], interpolation_factor)
								item_node.position = new_position
						# spawn item
						else:
							# item not looted
							if world_state_buffer[2]["I"][item]['D']:
								AudioControl.play_audio("drop")
							spawn_item(item, world_state_buffer[2]["I"][item])
				# no items in future state -> despawn all
				else:
					var current_item_nodes = get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).get_children()
					for i in current_item_nodes:
							i.queue_free()
				###################################################################################
				if world_state_buffer[2]["M"].size() > 0:
					var current_projectile_nodes = get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).get_children()
					# remove items if current state has item but future does not have it
# warning-ignore:shadowed_variable
					for projectile in current_projectile_nodes:
						if not projectile.name in world_state_buffer[2]["M"].keys():
							projectile.queue_free()
# warning-ignore:shadowed_variable
					for projectile in world_state_buffer[2]["M"].keys():
						if not world_state_buffer[1]["M"].has(projectile):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).has_node(str(projectile)):
							# floor both world state item locations 
							var ws1 = Vector2(floor(world_state_buffer[1]["M"][projectile]["P"].x), floor(world_state_buffer[1]["M"][projectile]["P"].y))
							var ws2 = Vector2(floor(world_state_buffer[2]["M"][projectile]["P"].x), floor(world_state_buffer[2]["M"][projectile]["P"].y))
							# if they are equal dont update the location
							if ws1 != ws2:
								var projectile_node = get_node("/root/GameWorld/MapNode/%s/Projectiles/" % Global.current_map + str(projectile))

								var new_position = lerp(world_state_buffer[1]["M"][projectile]["P"], world_state_buffer[2]["M"][projectile]["P"], interpolation_factor)
								projectile_node.position = new_position
						# spawn projectile
						else:
							spawn_projectile(projectile, world_state_buffer[2]["M"][projectile])
				# no projectile in future state -> despawn all
				else:
					var current_projectile_nodes = get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).get_children()
					for i in current_projectile_nodes:
							i.queue_free()
				#####################################################################################
				if world_state_buffer[2].has("N") and  world_state_buffer[1].has("N"):
					#spawn monsters function
					for npc in world_state_buffer[2]["N"].keys():
						if get_node("/root/GameWorld/MapNode/%s/NPCs" % Global.current_map).has_node(str(npc)):
							var npc_node = get_node("/root/GameWorld/MapNode/%s/NPCs/" % Global.current_map + str(npc))
							var new_position = lerp(world_state_buffer[1]["N"][npc], world_state_buffer[2]["N"][npc], interpolation_factor)
							npc_node.move(new_position)
				#####################################################################################
			# we have no future world_state
			elif render_time > world_state_buffer[1].T:
				despawn_players(world_state_buffer[1]["P"].keys())
				if current_map != world_state_buffer[1]["ID"]:
					return
				var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
				for player_state in world_state_buffer[1]["P"].keys():
					if player_state == get_tree().get_network_unique_id():
						continue
					if not world_state_buffer[0]["P"].has(player_state):
						continue
					if world_state_buffer[0]["P"][player_state]["M"] == Global.current_map:
						# move char if other character scene is in client, this should be later be determined by the server
						if get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_state)):
							var player_container = get_node("/root/GameWorld/MapNode/%s/OtherPlayers/" % Global.current_map + str(player_state))
							var position_delta = (world_state_buffer[1]["P"][player_state]["P"] - world_state_buffer[0]["P"][player_state]["P"])
							var new_position = world_state_buffer[1]["P"][player_state]["P"] + (position_delta * extrapolation_factor)
							var animation = world_state_buffer[1]["P"][player_state]["A"]
							player_container.move_player(new_position, animation)
						else:
							print("not spawned")
							spawn_new_player(player_state, world_state_buffer[1]["P"][player_state])
					else:
						if get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_state)):
							pass
							#despawn_player(player_state)
				if world_state_buffer[1]["E"].size() > 0:
					#spawn monsters function
					for monster in world_state_buffer[1]["E"].keys():
						if not world_state_buffer[0]["E"].has(monster):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Monsters" % Global.current_map).has_node(str(monster)):
							var monster_node = get_node("/root/GameWorld/MapNode/%s/Monsters/" % Global.current_map + str(monster))
							if world_state_buffer[0]["E"][monster]["EnemyHealth"] > monster_node.current_hp:
								monster_node.damage_taken(world_state_buffer[0]["E"][monster]["EnemyHealth"], world_state_buffer[0]["E"][monster]["DamageList"])
							else:
								if world_state_buffer[1]["E"][monster]["MissCounter"] > monster_node.miss_counter:
									monster_node.miss_counter += 1
									monster_node.damage_taken(world_state_buffer[0]["E"][monster]["EnemyHealth"], world_state_buffer[0]["E"][monster]["DamageList"])
							# monster dead on server
							if world_state_buffer[1]["E"][monster]["EnemyHealth"] <= 0:
								if monster_node.despawn != 0:
									print("Global Stop 3")
									monster_node.on_death()
							else:
								var new_position = world_state_buffer[1]["E"][monster]["EnemyLocation"]
								monster_node.move(new_position, world_state_buffer[1]["E"][monster]["EnemyState"], world_state_buffer[1]["E"][monster]["Direction"])
						else:
							# if actually alive respawned monster
							if world_state_buffer[1]["E"][monster]['time_out'] != 0 && world_state_buffer[1]["E"][monster]['EnemyState'] != "Dead":
								spawn_monster(monster, world_state_buffer[1]["E"][monster])
				#################################################################
				if world_state_buffer[1]["I"].size() > 0:
					var current_item_nodes = get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).get_children()
					# remove items if current state has item but future does not have it
					for item in current_item_nodes:
						if not item.name in world_state_buffer[1]["I"].keys():
							item.queue_free()
					for item in world_state_buffer[1]["I"].keys():
						if not world_state_buffer[0]["I"].has(item):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).has_node(str(item)):
							# floor both world state item locations 
							var ws1 = Vector2(floor(world_state_buffer[0]["I"][item]["P"].x), floor(world_state_buffer[0]["I"][item]["P"].y))
							var ws2 = Vector2(floor(world_state_buffer[1]["I"][item]["P"].x), floor(world_state_buffer[1]["I"][item]["P"].y))
							# if they are equal dont update the location
							if ws1 != ws2:
								var item_node = get_node("/root/GameWorld/MapNode/%s/Items/" % Global.current_map + str(item))
								var new_position = world_state_buffer[1]["I"][item]["P"]
								item_node.position = new_position
						# spawn item
						else:
							# item not looted:
							if world_state_buffer[1]["I"][item]['D']:
								AudioControl.play_audio("drop")
							spawn_item(item, world_state_buffer[1]["I"][item])
				# no items in future state -> despawn all
				else:
					var current_item_nodes = get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).get_children()
					for i in current_item_nodes:
							i.queue_free()
				#################################################################
				if world_state_buffer[1]["M"].size() > 0:
					var current_projectile_nodes = get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).get_children()
					# remove items if current state has item but future does not have it
# warning-ignore:shadowed_variable
					for projectile in current_projectile_nodes:
						if not projectile.name in world_state_buffer[1]["M"].keys():
							projectile.queue_free()
# warning-ignore:shadowed_variable
					for projectile in world_state_buffer[1]["M"].keys():
						if not world_state_buffer[0]["M"].has(projectile):
							continue
						# monster not dead on client
						if get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).has_node(str(projectile)):
							# floor both world state item locations 
							var ws1 = Vector2(floor(world_state_buffer[0]["M"][projectile]["P"].x), floor(world_state_buffer[0]["M"][projectile]["P"].y))
							var ws2 = Vector2(floor(world_state_buffer[1]["M"][projectile]["P"].x), floor(world_state_buffer[1]["M"][projectile]["P"].y))
							# if they are equal dont update the location
							if ws1 != ws2:
								var projectile_node = get_node("/root/GameWorld/MapNode/%s/Projectiles/" % Global.current_map + str(projectile))
								var new_position = world_state_buffer[1]["M"][projectile]["P"]
								projectile_node.position = new_position
						# spawn item
						else:
							spawn_projectile(projectile, world_state_buffer[1]["M"][projectile])
				# no items in future state -> despawn all
				else:
					var current_projectile_nodes = get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).get_children()
					for i in current_projectile_nodes:
							i.queue_free()
				#################################################################
				if world_state_buffer[1].has("N"):
					#spawn monsters function
					for npc in world_state_buffer[1]["N"].keys():
						if get_node("/root/GameWorld/MapNode/%s/NPCs" % Global.current_map).has_node(str(npc)):
							var npc_node = get_node("/root/GameWorld/MapNode/%s/NPCs/" % Global.current_map + str(npc))
							var new_position = world_state_buffer[1]["N"][npc]
							npc_node.move(new_position)
				#################################################################
				

func spawn_new_player(player_id: int, player_state: Dictionary) -> void:
	if player_id == get_tree().get_network_unique_id():
		pass
	else:
		var new_player = player_template.instance()
		new_player.position = get_node("/root/GameWorld/MapNode/%s" % Global.current_map).spawn_location
		new_player.name = str(player_id)
		get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).add_child(new_player)
		var player_container = get_node("/root/GameWorld/MapNode/%s/OtherPlayers/%s" % [Global.current_map,str(player_id)])
		player_container.display_name.text = player_state["U"]
		player_container.chat_box.display_name = player_state["U"]
		player_container.update_sprite(player_state["S"])

func despawn_player(player_id: int) -> void:
	if get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_id)):
		var character_node = get_node("/root/GameWorld/MapNode/%s/OtherPlayers/%s" % [Global.current_map, str(player_id)])
		character_node.visible = false
		character_node.queue_free()
		
func spawn_monster(monster_id: int, monster_dict: Dictionary) -> void:
	var monster = GameData.monster_preload[monster_dict['id']].instance()
	monster.monster_id = monster_dict['id']
	monster.position = monster_dict["EnemyLocation"]
	monster.title = GameData.monsterTable[monster_dict["id"]]["title"]
	monster.max_hp = GameData.monsterTable[monster_dict["id"]]["maxHP"]
	monster.current_hp = monster_dict["EnemyHealth"]
	monster.miss_counter = monster_dict["MissCounter"]
	monster.name = str(monster_id)
	get_node("/root/GameWorld/MapNode/%s/Monsters" % Global.current_map).add_child(monster, true)
	
func spawn_item(name: String, item_dict: Dictionary) -> void:
	"""
	worldstate[item integer >= 0 ]: {"P": item.position, "I": item.id}
	"""
	if item_dict['I'] == "100000":
		var item = GameData.item_preload["100000"].instance()
		item.position = item_dict["P"]
		item.name = name
		get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).add_child(item, true)
	else:
		var item = GameData.item_preload["item"].instance()
		item.position = item_dict["P"]
		item.name = name
		item.id = item_dict["I"]
		item.item_type = GameData.itemTable[str(item.id)]['itemType']
		get_node("/root/GameWorld/MapNode/%s/Items" % Global.current_map).add_child(item, true)

func spawn_projectile(name: String, projectile_world_state: Dictionary) -> void:
	var new_projectile = projectile.instance()
	new_projectile.name = name
	new_projectile.texture = load(GameData.skill_class_dictionary[projectile_world_state["I"]].projectile_sprite)
	new_projectile.position = projectile_world_state["P"]
	get_node("/root/GameWorld/MapNode/%s/Projectiles" % Global.current_map).add_child(new_projectile, true)
	
	
func server_reconciliation(server_input_data: Dictionary) -> void:
	for i in range(input_queue.size()):
		if server_input_data["T"] == input_queue[i]["T"]:
			if server_input_data["P"] != input_queue[i]["P"]:
#				var serverx = stepify(server_input_data["P"].x, 1)
#				var servery = stepify(server_input_data["P"].y, 1)
#				var clientx = stepify(input_queue[i]["P"].x, 1)
#				var clienty = stepify(input_queue[i]["P"].y, 1)
				var serverx = int(server_input_data["P"].x)
				var servery = int(server_input_data["P"].y)
				var clientx = int(input_queue[i]["P"].x)
				var clienty = int(input_queue[i]["P"].y)
# warning-ignore:shadowed_variable
				var player_node = get_node("/root/GameWorld/MapNode/%s/Player" % Global.current_map)
				if abs(serverx - clientx) > 1 and player_node.is_climbing:
					var recon_position = lerp(input_queue[i]["P"],server_input_data["P"], 0.85)
					player_node.set_position(recon_position)
				elif not player_node.is_on_floor() and not player_node.is_climbing:
					pass
				elif abs(serverx - clientx) > 25 or abs(servery - clienty) > 50:
					var recon_position = lerp(input_queue[i]["P"],server_input_data["P"], 0.50)
					player_node.set_position(recon_position)
			input_queue = input_queue.slice(i+1, input_queue.size(), 1, true)
			return

func test_movement():
	pass
	
func log_out() -> void:
	input_queue = []
	current_map = ""
	in_game = false

	last_world_state = 0
	world_state_buffer = []
	character_list = []
	player = null
	last_portal = null
	last_map = null
	player_position = null

func despawn_players(world_state_players: Array) -> void:
	var player_nodes = get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).get_children()
	for temp_player_node in player_nodes:
		if not int(temp_player_node.name) in world_state_players:
			temp_player_node.queue_free()

func array_comparison(future_arr: Array, current_arr: Array) -> bool:
	if not future_arr.hash() ==  current_arr.hash():
		return false
	else:
		return true

func process_quests_list() -> void:
	pass


func _on_Timer_timeout():
	Signals.emit_signal("connection_unsuccessful")
