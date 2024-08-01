######################################################################
# Game Server frontend to client : This is not a singleton. No other scripts should have
# direct influences on server calls except for global singleton.
# Responsible for communicating and interpreting all Client RPC Calls and convert to server
# responses
######################################################################
extends Node

var network = NetworkedMultiplayerENet.new()
var port: int = 2733
var max_players:int = 100

# example tokens added
var expected_tokens = []
onready var player_verification_process = get_node("PlayerVerification")
onready var character_creation_queue = []

#######################################################
# server netcode
#server start 
func _ready() -> void:
	Firebase.get_data(Firebase.FB_USERNAME, Firebase.FB_PASSWORD)
	

func start_server() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _process(_delta: float) -> void:
	create_characters()

# Player connect
func _Peer_Connected(player_id: int) -> void:
	print("User " + str(player_id) + " Connected")
	ServerData.player_location[str(player_id)] = 'connected'
	player_verification_process.start(player_id)

# when player disconnects
func _Peer_Disconnected(player_id: int) -> void:
	if ServerData.player_location[str(player_id)] == 'connected':
		ServerData.player_location.erase(str(player_id))
	else:
		var player_container = _Server_Get_Player_Container(player_id)
		if not "CharacterSelect" in ServerData.player_location[str(player_id)]:
			var cur_character = player_container.current_character
			var firebase = Firebase.update_document("characters/%s" % str(cur_character['displayname']), player_container.db_info["token"], cur_character)
			yield(firebase, 'completed')
			var firebase2 = Firebase.update_document("quests/%s" % str(cur_character['displayname']), player_container.db_info["token"], ServerData.quest_data[cur_character['displayname']])
			yield(firebase2, 'completed')
		else:
			print("dc in characterselect did not save")
		_Server_Data_Remove_Player(player_id)
		player_container.logging_timer.start()
		yield(player_container.logging_timer, "timeout")
		rpc_id(0, "despawn_player", player_id)
		player_container.queue_free()
	print("User " + str(player_id) + " Disconnected")

func _Server_Data_Remove_Player(player_id: int) -> void:
	ServerData.player_location.erase(str(player_id))
	ServerData.player_state_collection.erase(player_id)
	ServerData.logged_emails.erase(ServerData.player_id_emails[str(player_id)])
	ServerData.player_id_emails.erase(str(player_id))
	ServerData.ign_id_dict.erase(ServerData.username_list[str(player_id)])
	ServerData.username_list.erase(str(player_id))
	
func return_token_verification_results(player_id: int, result: bool) -> void:
	if result != false:
		var player_container = _Server_Get_Player_Container(player_id)
		if player_container.characters.empty():
			rpc_id(player_id, "return_token_verification_results", result, [])
		else:
			rpc_id(player_id, "return_token_verification_results", result, player_container.characters_info_list)
			#load character data
			if result == true:
				pass
	else:
		network.disconnect_peer(player_id)
		print("playercontainer empty probably big issue")

func fetch_token(player_id: int):
	rpc_id(player_id, "fetch_token")
	
func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			var token_time = int(expected_tokens[i].right(936))
			# deletes tokens older or future
			if current_time - token_time >= 30 or current_time - token_time < 0:
				expected_tokens.remove(i)
		print("Expected Tokens:")
		print(expected_tokens)

remote func return_token(token, email):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token, email)

func already_logged_in(player_id, _email):
	rpc_id(player_id, "already_logged_in")
	network.disconnect_peer(player_id)

# client/server time sync
remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)
	
remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)

func _Server_Get_Player_Container(player_id):
	return get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)

func _Server_Get_Player_Map(player_id):
	#eturn get_node(ServerData.player_location[str(player_id)].get_parent().get_parent())
	return get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).map_id
	
######################################################################
# pre-spawn server functions

#character account
#create, ign checker, fetch player data, delete, spawn
func create_characters():
	if character_creation_queue.size() > 0:
		print("createCharacter found queue")
		#player_id, username, playerContainer, requester
		var character_array = character_creation_queue[0]
		character_creation_queue.remove(0)
		"""
		[player_id, char_dict, player_container, requester]
		"""
		
		if character_array[1]["un"] in ServerData.characters_data.keys():
			print("%s already taken." % character_array[1])
			rpc_id(character_array[0], "returnfetchUsernames", character_array[3], false)
		else:
			#[player_id, char_dict, player_container, requester]
			character_array[2].characters.append(character_array[1]["un"])
			var new_char = character_array[1]
			var temp_player = _Server_New_Character(new_char)
			temp_player.equipment.top.owner = temp_player.displayname
			temp_player.equipment.bottom.owner = temp_player.displayname
			temp_player.equipment.rweapon.owner = temp_player.displayname

			print("creating character")
			var firebase_call = Firebase.update_document("characters/%s" % temp_player["displayname"], character_array[2].db_info["token"], temp_player)
			yield(firebase_call, 'completed')
			
			temp_player.stats["buff"] = ServerData.buff_stats.duplicate(true)
			
			ServerData.characters_data[temp_player.displayname] = temp_player

			var firebase_call2 = Firebase.update_document("users/%s" % character_array[2].db_info["id"], character_array[2].db_info["token"], character_array[2])
			yield(firebase_call2, 'completed')
			
			# hunt [-1, 0, 0, 0]
			# interact [-1]
			# use [-1,]
			var quest_log = [[-1],[-1],[-1, 0],[-1, 0]]
			
			var firebase_call3 = Firebase.update_document("quests/%s" % temp_player["displayname"], character_array[2].db_info["token"], quest_log)
			yield(firebase_call3, 'completed')

			Global.http_requests.append([temp_player.equipment.top, character_array[2]])
			Global.http_requests.append([temp_player.equipment.bottom, character_array[2]])
			Global.http_requests.append([temp_player.equipment.rweapon, character_array[2]])
			
			character_array[2].characters_info_list.append(temp_player)

			# update client with new character
			rpc_id(character_array[0], "return_create_characters", character_array[3], character_array[2].characters_info_list)

func _Server_New_Character(new_char: Dictionary):
	var temp_player = ServerData.static_data.player_template.duplicate(true)
	temp_player['displayname'] = new_char["un"]
	
	var sprite = temp_player["avatar"]
	sprite["bcolor"] = new_char["bc"]
	sprite["body"] = new_char["b"]
	sprite["head"] = new_char["he"]
	sprite["hcolor"] = new_char["hc"]
	sprite["hair"] = new_char["h"]
	sprite["eye"] = new_char["e"]
	sprite["ecolor"] = new_char["ec"]
	sprite["mouth"] = new_char["m"]
	sprite["ear"] = new_char["ea"]
	sprite["brow"] = new_char["br"]
	
	"""
		outfit:
		0: top: 500000, bottom: 500001
	 	1: top: 500002, bottom: 500003
		2: top: 500004, bottom: 500005
	"""
	var equips = temp_player["equipment"]
	if new_char["o"] == 0:
		var top = ServerData.equipmentTable[ServerData.static_data.starter_equips[0][0]].duplicate(true)
		top["id"] = str((ServerData.static_data.starter_equips[0][0]))
		top["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[0][0]))
		equips["top"] = top
		
		var bottom = ServerData.equipmentTable[ServerData.static_data.starter_equips[0][1]].duplicate(true)
		bottom["id"] = str(ServerData.static_data.starter_equips[0][1])
		bottom["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[0][1]))
		equips["bottom"] = bottom
		
	elif new_char["o"] == 1:
		var top = ServerData.equipmentTable[ServerData.static_data.starter_equips[1][0]].duplicate(true)
		top["id"] = str((ServerData.static_data.starter_equips[1][0]))
		top["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[1][0]))
		equips["top"] = top
		
		var bottom = ServerData.equipmentTable[ServerData.static_data.starter_equips[1][1]].duplicate(true)
		bottom["id"] = str(ServerData.static_data.starter_equips[1][1])
		bottom["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[1][1]))
		equips["bottom"] = bottom
		
	else:
		var top = ServerData.equipmentTable[ServerData.static_data.starter_equips[2][0]].duplicate(true)
		top["id"] = str((ServerData.static_data.starter_equips[2][0]))
		top["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[2][0]))
		equips["top"] = top
		
		var bottom = ServerData.equipmentTable[ServerData.static_data.starter_equips[2][1]].duplicate(true)
		bottom["id"] = str(ServerData.static_data.starter_equips[2][1])
		bottom["uniqueID"] = str(Global.generate_unique_id(ServerData.static_data.starter_equips[2][1]))
		equips["bottom"] = bottom
	
	var weapon = ServerData.equipmentTable["200000"].duplicate(true)
	weapon["id"] = "200000"
	weapon["uniqueID"] = str(Global.generate_unique_id("200000"))
	equips.rweapon = weapon
	#############################################################################
	return temp_player
	
remote func choose_character(requester: int, display_name: String) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	for character_dict in player_container.characters_info_list:
		if  display_name == character_dict['displayname']:
			player_container.current_character = ServerData.characters_data[display_name]
			#print(player_container.current_character.inventory)
			ServerData.username_list[str(player_id)] = display_name
			ServerData.ign_id_dict[(display_name)] = str(player_id)
			break
	var map = player_container.current_character['map']
	var temp_dict = player_container.current_character.avatar
	player_container.sprite.append(str(temp_dict.bcolor) + str(temp_dict.body))
	player_container.sprite.append(str(temp_dict.brow))
	player_container.sprite.append(str(temp_dict.bcolor) + str(temp_dict.ear))
	player_container.sprite.append(str(temp_dict.ecolor) + str(temp_dict.eye))
	player_container.sprite.append(str(temp_dict.hcolor) + str(temp_dict.hair))
	# below is head sprite. Set to bcolor due to issue where headspite # doesnt matter
	# character creation is front facing while in game is side profile. 
	player_container.sprite.append(str(temp_dict.bcolor))
	player_container.sprite.append(str(temp_dict.mouth))
	
	var equipment_list = ["headgear", "top", "bottom", "rweapon", "lweapon", "eyeacc", "earring", "faceacc", "glove", "tattoo"]
	temp_dict = player_container.current_character.equipment
	for equip in equipment_list:
		if temp_dict[equip]:
			player_container.sprite.append(str(temp_dict[equip].id))
		else:
			player_container.sprite.append(null)
	
	# move user container to the map
	if map == "100001" and int(player_container.current_character.stats.base.level) == 1 and int(player_container.current_character.stats.base.experience) == 0:
		move_player_container(player_id, player_container, map, 'start')
	else:
		move_player_container(player_id, player_container, map, 'spawn')
	player_container.load_player_stats()
	player_container.start_idle_timer()
	update_attack_range(player_container)
	Global.calculate_stats(player_container.current_character)
	rpc_id(player_id, "send_quest_data", ServerData.quest_data[display_name])
	rpc_id(player_id, "return_choose_character", requester)

remote func fetch_usernames(requester, username: String) -> void:
	print("inside fetch username. Username: %s" % username)
	var player_id = get_tree().get_rpc_sender_id()
	if username in ServerData.user_characters.keys():
		print("%s already taken." % username)
		rpc_id(player_id, "return_fetch_usernames", requester, false)
	else:
		print("%s not taken." % username)
		# call create character function
		# update database,  server player container, send updated information to client
		rpc_id(player_id, "return_fetch_usernames", requester, true)
		pass

remote func create_character(requester, char_dict: Dictionary) -> void:
	print("create_character: Username: %s" % char_dict["un"])
	var player_id = get_tree().get_rpc_sender_id()
	var player_container =_Server_Get_Player_Container(player_id)
	character_creation_queue.append([player_id, char_dict, player_container, requester])

# warning-ignore:unused_argument
remote func delete_character(requester, display_name: String) -> void:
	""" 
		var characters = []
		var characters_info_list = []
	"""
	print("atempting to delete %s" % display_name)

	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)

	# find index from character array delete index in characters and charaters info list
	var index = player_container.characters.find(display_name)
	player_container.characters.remove(index)
	player_container.characters_info_list.remove(index)

	var firebase_call = Firebase.update_document("users/%s" % player_container.db_info["id"], player_container.db_info["token"], player_container)
	yield(firebase_call, "completed")
	var firebase_call2 = Firebase.delete_document("characters/%s" % display_name, player_container.db_info["token"])
	yield(firebase_call2, "completed")
	var firebase_call3 = Firebase.delete_document("quests/%s" % display_name, player_container.db_info["token"])
	yield(firebase_call3, "completed")
	rpc_id(player_id, "return_delete_character", player_container.characters_info_list, requester)

remote func logout() -> void:
	var player_id = get_tree().get_rpc_sender_id()
# warning-ignore:unused_variable
	var player_container = _Server_Get_Player_Container(player_id)
	player_container.loggedin = false
	network.disconnect_peer(player_id)

######################################################################
# ingame functions account/character container 

func despawnPlayer(player_id) -> void:
	rpc_unreliable_id(0, "receive_despawn_player", player_id)

# arugment is a player container
func update_player_stats(player_container: KinematicBody2D) -> void:
	#print(get_stack())
	rpc_id(int(player_container.name), "update_player_stats", player_container.current_character)

# Character containers/information 
func move_player_container(player_id: int, player_container: KinematicBody2D, map_id: String, position) -> void:
	"""
	position can be string or vector2
	string = spawn
	vector2 = move to destination
	"""
	var old_parent = get_node(str(ServerData.player_location[str(player_id)]))
	var new_parent = get_node("/root/Server/World/Maps/%s/YSort/Players" % str(map_id))

	old_parent.remove_child(player_container)
	new_parent.add_child(player_container)

	ServerData.player_location[str(player_id)] = "/root/Server/World/Maps/" + str(map_id) + "/YSort/Players"
	var player = get_node("/root/Server/World/Maps/" + str(map_id) + "/YSort/Players/" + str(player_id))
	var map_node = get_node("/root/Server/World/Maps/%s" % str(map_id))
	var map_position = map_node.get_global_position()

	if typeof(position) == TYPE_STRING and position == "spawn":
		position = Vector2(map_node.spawn_position.x, map_node.spawn_position.y)
	elif typeof(position) == TYPE_STRING and position == "start":
		position = Vector2(map_node.first_spawn.x, map_node.first_spawn.y)

	player.position = position

func get_player_data(player_id):
	
	var player_container = _Server_Get_Player_Container(player_id)
	# warning-ignore:unused_variable
	var character_count = player_container.db_info

remote func portal(portal_id):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# validate
	var portal = ServerData.player_location[str(player_id)].replace("YSort/Players", "MapObjects/%s" % portal_id)
	# get portal node
	get_node(portal).over_lapping_bodies(player_id)
	rpc_id(player_id, "return_portal", player_id)

	#get nextmap name
	var map_id = get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).map_id
	var next_map = ServerData.portal_data[map_id][portal_id]['map']
	# get mapname, move user container to the map
	move_player_container(player_id, player_container, next_map, ServerData.portal_data[map_id][portal_id]['spawn'])
	#print('update current character last map')
	player_container.current_character['map'] = next_map

	update_player_stats(player_container)

	#print("update character list last map")
	for character in player_container.characters_info_list:
		if character['displayname'] == player_container.current_character['displayname']:
			character['map'] = player_container.current_character['map']

	# send rpc to client to change map
	rpc_id(player_id, "change_map", next_map, ServerData.portal_data[map_id][portal_id]['spawn'])
	# put some where if world state != current map ignore
#######################################################
# ingame world functions 

#world states
remote func received_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	var input = player_state["P"]
	# [up, down, left, right, jump, loot]
	if  input != [0,0,0,0,0,0]:
		player_container.input_queue.append(player_state["P"])

	#var map_node = get_node(ServerData.player_location[str(player_id)])

	player_state["U"] = ServerData.username_list[str(player_id)]
	player_state["P"] = player_container.position
	# takes client tick time and sends it with final position
	var return_input = {'T': player_state['T'], 'P': player_container.position}
	return_player_input(player_id, return_input)
	var map_id = ServerData.player_location[str(player_id)].replace("/root/Server/World/Maps/", "")
	map_id = map_id.replace("/YSort/Players", "")
	player_state['M'] = map_id
	player_state['A'] = (player_container.get_animation()).duplicate(true)
	player_state['S'] = player_container.sprite
	if ServerData.player_state_collection.has(player_id):
		if ServerData.player_state_collection[player_id]["T"] < player_state["T"]:
			ServerData.player_state_collection[player_id] = player_state
	# just logged in add player state
	else:
		 ServerData.player_state_collection[player_id] = player_state

func return_player_input(player_id: int, server_input_data) -> void:
	rpc_id(player_id, "return_player_input", server_input_data)

func send_world_state(player_list: Array, map_state: PoolByteArray):
	for player in player_list:
		rpc_unreliable_id(int(player), "receive_world_state", map_state)

###############################################################################
# server combat functions
remote func receive_input(move_id):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# basic attack
	if move_id == 0:
		if player_container.attacking == false and not player_container.current_character.equipment.rweapon == null:
			player_container.attacking = true
			player_container.animation_state["a"] = 0
			player_container.attack_timer.wait_time = 1.0 / ServerData.static_data.weapon_speed[player_container.current_character.equipment.rweapon.attackSpeed]
			player_container.attack_timer.start()
			player_container.normal_attack()
	#uses skill
	else:
		if move_id in ServerData.job_skills[player_container.current_character.stats.job]:
			if player_container.current_character.equipment.rweapon in ServerData.cl_dict[player_container.current_character.stats.job]["Weapon"]:
				if player_container.skill_id_cd:
					print("skill on cd")
				if player_container.current_character.stats.mana > 0:
					if move_id.type == "buff":
						print("playey use buff ", move_id)
					# move == attack
					else:
						if ServerData.job_dict[player_container.current_character.stats.job]["Range"] == 1 && ServerData.job_dict[player_container.current_character.equipment.ammo["quantity"]] == 0:
							return "no ammo"
						else:
							player_container.attack(move_id)
				else:
					print("not enough mana")
			else:
				print("wrong weapon")
		else:
			print("ya cheating banned")
	
# 0 = no climb
# 1 = can climb
func send_climb_data(player_id: int, climb_data: int):
	#print("%s climb data %s" % [player_id, climb_data])
	rpc_id(int(player_id), "receive_climb_data", climb_data)

remote func move_item(inv_data: Array):
	"""
	inv_data=[tab:int, from:int, to:int]
	assuming from_item != null (you cant drag and drop empty slots)
	"""
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	var tab = {0: "equipment", 1: "use", 2: "etc"}

	var item1 = player_container.current_character.inventory[tab[inv_data[0]]][inv_data[1]]
	# if to_slot != null -> to_slot = from_slot, from_slot = to_slot
	if player_container.current_character.inventory[tab[inv_data[0]]][inv_data[2]] != null:
		var item2 = player_container.current_character.inventory[tab[inv_data[0]]][inv_data[2]]
		player_container.current_character.inventory[tab[inv_data[0]]][inv_data[2]] = item1
		player_container.current_character.inventory[tab[inv_data[0]]][inv_data[1]] = item2
	# if to_slot = null -> to_slot = from_slot, from_slot = null
	else:
		player_container.current_character.inventory[tab[inv_data[0]]][inv_data[2]] = item1
		player_container.current_character.inventory[tab[inv_data[0]]][inv_data[1]] = null
	# update client
	update_player_stats(player_container)

func transfer_item_ownership():
	"""
	this function should be called when item is traded or looted after previous owner drops.
	"""
	pass

func delete_item():
	"""
	remove item from database. this function should be called when:
		1. unique item is sold
		2. when item on floor dispears
		3. dropping unique item
	"""
	pass
####################################################################################

func send_client_notification(player_id, message: String) -> void:
	rpc_id(player_id, "server_message", message)
	
func send_loot_data(player_id: String, loot_data: Dictionary) -> void:
	rpc_id(int(player_id), "loot_data", loot_data)

remote func use_item(item: Array) -> void:
	"""
	item_id[0] = item_id
	item_id[1] = index slot
	"""
	# get player container
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# if item in inventory
	if item[0] == player_container.current_character.inventory.use[item[1]].id:
		# if item count > 0
		if player_container.current_character.inventory.use[item[1]].q > 0:
			if player_container.current_character.inventory.use[item[1]].q == 1:
				player_container.current_character.inventory.use[item[1]] = null
			elif player_container.current_character.inventory.use[item[1]].q > 2:
				player_container.current_character.inventory.use[item[1]].q -= 1
			
			# get item type and amount
			var quantity = ServerData.itemTable[item[0]].useAmount
			
			"""
			check if item of quest item
			get list of all active use quests
			check if item is in requirements
			check off item used
			"""
			var quest_id = 0
			# for each quest
			while quest_id < ServerData.questTable.size():
				# if item is use
				if ServerData.questTable[str(quest_id)].type == "use":
					# if item in quest required
					if int(item[0]) == int(ServerData.questTable[str(quest_id)].questReq):
						# update quest_data[quest_id][turn_in_info][item_index] = finished
						# ServerData.quest_data[player_container.current_character.displayname][quest_id][1] = quest["req"]
						ServerData.quest_data[player_container.current_character.displayname][quest_id][1] = 1
				quest_id += 1
				
			if ServerData.itemTable[item[0]]["useType"] == "health":
				print("health pot")
				var total_health = player_container.current_character.stats.base.maxHealth + player_container.current_character.stats.equipment.maxHealth  
				# if over heal -> set max, else +=
				if player_container.current_character.stats.base.health + quantity > total_health:
					player_container.current_character.stats.base.health = total_health
				else:
					player_container.current_character.stats.base.health += quantity
				
			elif ServerData.itemTable.use[item]["useType"] == "mana":
				print("mana pot")
				var total_mana = player_container.current_character.stats.base.maxMana + player_container.current_character.stats.equipment.maxMana
				# if over heal -> set max, else +=
				if player_container.current_character.stats.base.mana + quantity > total_mana:
					player_container.current_character.stats.base.mana = total_mana
				else:
					player_container.current_character.stats.base.mana += quantity
			# not implemented yet
			# + stats
			else:
				print("status pot")
			update_player_stats(player_container)
			send_client_notification(player_id, "used %s" % ServerData.itemTable[item[0]].itemName)
		# amount of pots = 0 should not be in data
		else:
			print("not enough pots")
			update_player_stats(player_container)
			send_client_notification(player_id, "not enough %s" % ServerData.itemTable[item[0]].itemName)

remote func add_stat(stat: String) -> void:
	# get player container
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	if player_container.current_character.stats.base.sp > 0:
		player_container.current_character.stats.base.sp -= 1
		if stat == "s":
			player_container.current_character.stats.base.strength += 1
		elif stat == "w":
			player_container.current_character.stats.base.wisdom += 1
		elif stat == "d":
			player_container.current_character.stats.base.dexterity += 1
		else:
			player_container.current_character.stats.base.luck += 1
		update_player_stats(player_container)
		send_client_notification(player_id, "added 1 to %s" % stat)
	else:
		send_client_notification(player_id, "not enough sp")
	
func save(var path : String, var thing_to_save):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(JSON.print(thing_to_save, "\t"))
	file.close()

remote func send_chat(text: String, chat_type: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	print("%s said %s" % [player_id, text])
	var player_container = _Server_Get_Player_Container(player_id)
	ServerData.chat_logs.append({"email": player_container.email, "ign": player_container.current_character.displayname, "time": OS.get_unix_time(), "msg": text, "chatType": chat_type})
	# in map
	if chat_type == 0:
		var map_player_list = get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).players
		for player in map_player_list:
			rpc_id(int(player.name), "update_messages", str(player_id), player_container.current_character.displayname, text, chat_type)
	# in friends
	elif chat_type == 1:
		pass
	# in party
	elif chat_type == 2:
		pass
	# in guild
	elif chat_type == 3:
		pass
#	#in whisper
#	elif chat_type == 1:
#		pass

remote func drop_request(slot: int, tab: String, quantity: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	var player_position = player_container.position
	var map_id = _Server_Get_Player_Map(player_id)
	Global.player_drop_item(player_container, player_position, map_id, tab, slot, quantity)
	
	# check if has item
	
func _unhandled_input(event):
	pass

remote func update_keybind(key: String, type: String, id: String) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	print(type, " and ", id)
	
	if type == "use":
		# check item is in inventory
		for item in player_container.current_character.inventory.use:
			if not item == null:
				# if item is in inventory
				if item.id == id:
					# if item bind to different keybind
					for keybind in player_container.current_character.keybind.keys():
						if player_container.current_character.keybind[keybind] == id:
							player_container.current_character.keybind[keybind] = null
							break
					# assign item to new keybind
					player_container.current_character.keybind[key] = id
					update_player_stats(player_container)
					print("update %s keybind: key %s with %s %s" % [player_id, key, type, id])
					break
					
	elif type == "skill":
		# if character id has skill
		if id in ServerData.skill_class_dictionary.keys():
			# get skill location in dictionary
			var location = ServerData.skill_class_dictionary[id].location
			# if skill level > 1
			if player_container.current_character.skills[location[0]][location[1]] != 0:
				# check if skill bound to different keybind
				for keybind in player_container.current_character.keybind.keys():
					if player_container.current_character.keybind[keybind] == id:
						player_container.current_character.keybind[keybind] = null
						break
				player_container.current_character.keybind[key] = id
				update_player_stats(player_container)
				print("update %s keybind: key %s with %s %s" % [player_id, key, type, id])
	else:
		for keybind in player_container.current_character.keybind.keys():
					if player_container.current_character.keybind[keybind] == id:
						player_container.current_character.keybind[keybind] = null
						break
						
		player_container.current_character.keybind[key] = id
		update_player_stats(player_container)
		print("update %s keybind: key %s with %s %s" % [player_id, key, type, id])
		
remote func swap_keybind(key1: String, key2: String) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	var temp_key = player_container.current_character.keybind[key1]
	player_container.current_character.keybind[key1] = player_container.current_character.keybind[key2]
	player_container.current_character.keybind[key2] = temp_key
	update_player_stats(player_container)
	print("player %s swap key %s and key %s" % [player_id, key1, key2])

remote func remove_keybind(key: String) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	player_container.current_character.keybind[key] = null
	update_player_stats(player_container)
	print("player %s remove keybind %s" % [player_id, key])

remote func skill_request(skill: String) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	if player_container.attacking == false and not player_container.current_character.equipment.rweapon == null:
		var skill_class
		var skill_data
		
		if ServerData.skill_class_dictionary.has(skill):
			skill_class = ServerData.skill_class_dictionary[skill]
			
			# not on cd
			if not player_container.cooldowns.has(skill):
				# if beginner skill or player job in job skills
				if skill_class.location[0] == "0" or player_container.current_character.stats.job in skill_class.class:
					
					skill_data = ServerData.skill_data[skill_class.location[0]][skill_class.location[1]]
					if skill_data.type == "attack" and player_container.is_climbing:
						print("%s used attack still but is climbing" % player_container.current_character.displayname)
						return
					# get skill level
					var player_skill_data = player_container.current_character.skills[skill_class.location[0]][skill_class.location[1]]
					if player_container.current_character.displayname == "1111111":
						player_container.current_character.stats.base.mana = player_container.current_character.stats.base.maxMana
					# check mana cost
					if player_container.current_character.stats.base.mana >= skill_data.mana[player_skill_data - 1]:
						# update mana
						player_container.current_character.stats.base.mana -= skill_data.mana[player_skill_data - 1]
						# if buff
						player_container.attacking = true
						if skill_data.type == "buff": 
							if not player_container.buffs.has(skill):
								var keys = skill_data.stat.keys()
								for key in keys:
									if "Percent" in key and "strength" in key:
											player_container.current_character.stats.buff["strength"] += floor(player_container.current_character.stats.base.strength * skill_data.stat[key][player_skill_data - 1])
									elif "Percent" in key and "dexterity" in key:
										player_container.current_character.stats.buff["dexterity"] += floor(player_container.current_character.stats.base.dexterity * skill_data.stat[key][player_skill_data - 1])
									elif "Percent" in key and "wisdom" in key:
										player_container.current_character.stats.buff["wisdom"] += floor(player_container.current_character.stats.base.wisdom * skill_data.stat[key][player_skill_data - 1])
									elif "Percent" in key and "luck" in key:
										player_container.current_character.stats.buff["luck"] += floor(player_container.current_character.stats.base.luck * skill_data.stat[key][player_skill_data - 1])
									elif "Percent" in key and "health" in key:
										player_container.current_character.stats.buff["maxHealth"] += floor(player_container.current_character.stats.base.maxHealth * skill_data.stat[key][player_skill_data - 1])
									elif "Percent" in key and "mana" in key:
										player_container.current_character.stats.buff["maxMana"] += floor(player_container.current_character.stats.base.maxMana * skill_data.stat[key][player_skill_data - 1])
									else:
										player_container.current_character.stats.buff[key] += skill_data.stat[key][player_skill_data - 1]
								#player_container.current_character.stats.buff[skill] = {"stat": skill_data.statType, "A": skill_data.type, "D": skill_data.duration[player_skill_data - 1]}
							player_container.buffs[skill] = skill_data.duration[player_skill_data - 1]
							update_player_stats(player_container)
							
						elif skill_data.type == "heal":
							print("attempt to heal")
							var keys = skill_data.stat.keys()
							for key in keys:
								if key == "health":
									if player_container.current_character.stats.base.health + skill_data.stat[key][player_skill_data - 1] > player_container.current_character.stats.base.maxHealth + player_container.current_character.stats.buff.maxHealth:
										player_container.current_character.stats.base.health = player_container.current_character.stats.base.maxHealth + player_container.current_character.stats.buff.maxHealth
									else:
										player_container.current_character.stats.base.health += skill_data.stat[key][player_skill_data - 1]
										
								elif key == "mana":
									if player_container.current_character.stats.base.mana + skill_data.stat[key][player_skill_data - 1] > player_container.current_character.stats.base.maxMana + player_container.current_character.stats.buff.maxMana:
										player_container.current_character.stats.base.mana = player_container.current_character.stats.base.maxMana + player_container.current_character.stats.buff.maxMana
									else:
										player_container.current_character.stats.base.mana += skill_data.stat[key][player_skill_data - 1]
								else:
									player_container.current_character.stats.buff[key] += skill_data.stat[key][player_skill_data - 1]
							update_player_stats(player_container)
							
						# if attack
						elif skill_data.type == "attack":
							# if projectile
							if skill_data.attackType == "projectile":
								var projectile = ServerData.projectile_dict[skill].object.instance()
								projectile.id = skill
								projectile.skill_data = skill_data
								projectile.skill_level = player_skill_data - 1
								if player_container.direction == 1:
									projectile.position = player_container.position + ServerData.projectile_dict[skill].distance
								else:
									projectile.position = Vector2(player_container.position.x - ServerData.projectile_dict[skill].distance.x, player_container.position.y + ServerData.projectile_dict[skill].distance.y)
								projectile.player = player_container
								projectile.direction = player_container.direction
								get_node(str(ServerData.player_location[str(player_id)])).get_parent().get_node("Projectiles").add_child(projectile, true)
								# create projectile
							elif skill_data.attackType == "melee":
								pass
							elif skill_data.attackType == "aoe":
								pass
						# set cd
						var cooldown = skill_data.cooldown[player_skill_data - 1]
						if cooldown > 0:
							player_container.cooldowns[skill] = int(cooldown)
						else:
							print("%s does not have cooldown limit" % skill)
						player_container.animation_state["a"] = skill_data.animation
						player_container.attack_timer.wait_time = 1.0 / ServerData.static_data.weapon_speed[player_container.current_character.equipment.rweapon.attackSpeed]
						player_container.attack_timer.start()
			else:
				print("%s has %s is on cooldown" % [player_id, skill])
		else:
			print("%s not in skill data")

remote func increase_skill(skill_id: String, level: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	var skill_class = ServerData.skill_class_dictionary[skill_id]
	
	if skill_class.location[0] == "0" or player_container.current_player.stats.job in skill_class.class:
		print("inside")

		var skill_data = ServerData.skill_data[skill_class.location[0]][skill_class.location[1]]
		var player_skill_level = player_container.current_character.skills[skill_class.location[0]][skill_class.location[1]]
		print("maxLevel %s, player skill level: %s" % [skill_data.maxLevel, player_skill_level])
		
		if player_skill_level == level and player_container.current_character.stats.base.ap[skill_class.job] > 0 and player_skill_level < skill_data.maxLevel:
			print("inside 2")
			print("before %s %s lvl %s" %[player_container.current_character.stats.base.ap[skill_class.job], skill_id, player_skill_level])
			player_container.current_character.stats.base.ap[skill_class.job] -= 1
			player_container.current_character.skills[skill_class.location[0]][skill_class.location[1]] += 1
			print("after %s %s lvl %s" %[player_container.current_character.stats.base.ap[skill_class.job], skill_id, player_container.current_character.skills[skill_class.location[0]][skill_class.location[1]]])
			
			update_player_stats(player_container)

remote func equipment_request(equipment_slot, inventory_slot) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# get slot item type
	var item = player_container.current_character.inventory.equipment[inventory_slot]
	var equipment = player_container.current_character.equipment[equipment_slot]
	if equipment_swap_check(player_container, equipment_slot, equipment, item):
		var temp_equipment = equipment
		player_container.current_character.equipment[equipment_slot] = item
		player_container.current_character.inventory.equipment[inventory_slot] = temp_equipment
		# remove unequiped item stats
		if equipment:
			for stats in player_container.current_character.stats.equipment.keys():
				player_container.current_character.stats.equipment[stats] -= player_container.current_character.inventory.equipment[inventory_slot][stats]
		# add new equiped item stats
		for stats in player_container.current_character.stats.equipment.keys():
			player_container.current_character.stats.equipment[stats] += player_container.current_character.equipment[equipment_slot][stats]
		if equipment_slot == "rweapon":
			update_attack_range(player_container)
		
		# calcluate total stats
		Global.calculate_stats(player_container.current_character)
		update_player_stats(player_container)
		player_container.update_sprite_array()

remote func remove_equipment_request(equipment_slot, inventory_slot) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	var equipment = player_container.current_character.equipment[equipment_slot]
	
	if not player_container.current_character.inventory.equipment[inventory_slot]:
		player_container.current_character.inventory.equipment[inventory_slot] = equipment
		player_container.current_character.equipment[equipment_slot] = null
		
		for stats in player_container.current_character.stats.equipment.keys():
			player_container.current_character.stats.equipment[stats] -= player_container.current_character.inventory.equipment[inventory_slot][stats]
		
		if equipment_slot == "rweapon":
			update_attack_range(player_container)
		Global.calculate_stats(player_container.current_character)
		update_player_stats(player_container)
		player_container.update_sprite_array()
	else:
		print("inventory slot not null")
	#rpc_id(player_id, "return_remove_equipment", equipment_slot)

func equipment_swap_check(player, equipment_slot, equipment, item) -> bool:
	## JOB CHECK ###
	if not ServerData.equipmentTable[item.id].job == null and not ServerData.equipmentTable[item.id].job == player.current_character.stats.base.job:
		print("wrong job")
		return false
	## LEVEL CHECK ###
	if not ServerData.equipmentTable[item.id].reqLevel <= player.current_character.stats.base.level:
		print("wrong level")
		return false
	## STAT CHECK ###
	print("equipment slot check stats")
	if equipment:
		if not ServerData.equipmentTable[item.id].reqStr <= player.current_character.stats.base.strength + player.current_character.stats.buff.strength + player.current_character.stats.equipment.strength - equipment.strength:
			print("not enough str")
			return false
		if not ServerData.equipmentTable[item.id].reqWis <= player.current_character.stats.base.wisdom + player.current_character.stats.buff.wisdom + player.current_character.stats.equipment.wisdom - equipment.wisdom:
			print("not enough wis")
			return false
		if not ServerData.equipmentTable[item.id].reqLuk <= player.current_character.stats.base.luck + player.current_character.stats.buff.luck + player.current_character.stats.equipment.luck - equipment.luck:
			print("not enough luk")
			return false
		if not ServerData.equipmentTable[item.id].reqDex <= player.current_character.stats.base.dexterity + player.current_character.stats.buff.dexterity + player.current_character.stats.equipment.dexterity - equipment.dexterity:
			print("not enough dex")
			return false
	## STAT CHECK ###
	else:
		print("equipment slot check no equipment")
		if not ServerData.equipmentTable[item.id].reqStr <= player.current_character.stats.base.strength + player.current_character.stats.buff.strength + player.current_character.stats.equipment.strength:
			print("not enough str")
			return false
		if not ServerData.equipmentTable[item.id].reqWis <= player.current_character.stats.base.wisdom + player.current_character.stats.buff.wisdom + player.current_character.stats.equipment.wisdom:
			print("not enough wis")
			return false
		if not ServerData.equipmentTable[item.id].reqLuk <= player.current_character.stats.base.luck + player.current_character.stats.buff.luck + player.current_character.stats.equipment.luck:
			print("not enough luk")
			return false
		if not ServerData.equipmentTable[item.id].reqDex <= player.current_character.stats.base.dexterity + player.current_character.stats.buff.dexterity + player.current_character.stats.equipment.dexterity:
			print("not enough dex")
			return false
		
	## TYPE CHECK ###
	# if weapon right hand true
	print("pass equipment stat check")
	if ServerData.equipmentTable[item.id].type == "weapon":
		print("checking weapon")
		if equipment_slot == "rweapon":
			print("righthand")
			return true
		elif equipment_slot == "lweapon":
			print("lefthand")
			if player.current_character.stats.base.job in []:
				print("job in dual wield")
				return true
			else:
				print("job not in dual wield")
				return false
		else:
			print("weapon but not right hand or left hand")
			return false
	elif ServerData.equipmentTable[item.id].type == "shield" and equipment_slot == "lhand":
		print("sheild and left hand")
		return true
	elif ServerData.equipmentTable[item.id].type == equipment_slot:
		print("equipment and slot same type")
		return true
	else:
		print("incorrect slot")
		return false

func update_attack_range(player) -> void:
	var weapon = player.current_character.equipment.rweapon
	var attack_range_list = player.attack_range.get_children()
	if weapon:
		for i in attack_range_list:
			if i.name in weapon.weaponType:
				i.disabled = false
				i.visible = true
			else:
				i.disabled = true
				i.visible = false
	else:
		for i in attack_range_list:
			i.disabled = true
			i.visible = false

remote func accept_quest(quest_id):
	print("quest id is: %s" % str(quest_id))
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	var quest_data = ServerData.questTable[str(quest_id)]
	if not int(player_container.current_character.stats.base.level) >= int(quest_data.levelReq):
		print("level not high enough")
	if not ServerData.quest_data[player_container.current_character.displayname][quest_id][0] == -1:
		print("player already accepted quest")
	if quest_data.give:
		print("quest has give")
		# get item id from quest_data.questReq -> item_id
		var free
		var item_id = str(quest_data.give)
		var type = ServerData.itemTable[str(item_id)].itemType
		var index = 0
		var max_index = player_container.current_character.inventory[type].size() - 1
		print("needed item %s" % item_id)
		while index <= max_index - 1:
			if player_container.current_character.inventory[type][index]:
				if player_container.current_character.inventory[type][index].id == item_id:
					print("player has item already")
					break
			elif player_container.current_character.inventory[type][max_index]:
				if player_container.current_character.inventory[type][max_index].id == item_id:
					print("player has item already")
					break
			else:
				if not player_container.current_character.inventory[type][index] and (not free or index < free):
					print("index at %s" % index)
					free = index
				elif not player_container.current_character.inventory[type][max_index] and (not free or max_index < free):
					print("free slot at max index %s" % max_index)
					free = max_index
			index += 1
			max_index -= 1
		if free:
			print("adding item %s in slot %s" % [str(item_id), str(free)])
			player_container.current_character.inventory[type][free] = {'id': item_id, 'q': 1}
			self.update_player_stats(player_container)
		else:
			print("full inventory")
			rpc_id(player_id, "return_quest", 1)
			return
	print("%s accepcted quest %s" % [str(player_id), str(quest_id)])
	ServerData.quest_data[player_container.current_character.displayname][quest_id][0] = 0
	rpc_id(player_id, "send_quest_data", ServerData.quest_data[player_container.current_character.displayname])
	rpc_id(player_id, "return_quest", 0)

remote func turn_in_quest(quest_id) -> void:
	print("turn_in_quest")
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	var quest_data = ServerData.questTable[str(quest_id)]

	if quest_data.type == "interact":
		ServerData.quest_data[player_container.current_character.displayname][quest_id][0] = 9
		rpc_id(player_id, "send_quest_data", ServerData.quest_data[player_container.current_character.displayname])
		rpc_id(player_id, "return_quest", 2)
	elif quest_data.type == "hunt":
		var index = 1
		#print(ServerData.quest_data[player_container.current_character.displayname][quest_id][1])
		for count in ServerData.quest_data[player_container.current_character.displayname][quest_id][1]:
			print(count)
			if count == ServerData.questTable[str(quest_id)].questReq[index]:
				index += 2
				#print("next index %s" % str(index))
			else:
				print("player did not kill enough %s" % ServerData.questTable[str(quest_id)].questReq[index-1])
				rpc_id(player_id, "return_quest", -1)
				return
				
	elif quest_data.type == "use":
		if ServerData.quest_data[player_container.current_character.displayname][quest_id][1] == 1:
			ServerData.quest_data[player_container.current_character.displayname][quest_id][0] = 9
			rpc_id(player_id, "send_quest_data", ServerData.quest_data[player_container.current_character.displayname])
			rpc_id(player_id, "return_quest", 2)
		else:
			if Global.inventory_search(player_container, str(quest_data.questReq)):
				print("has item")
			else:
				print("does not have item")
				var slot = Global.empty_inventory_search(player_container, str(quest_data.questReq))
				if slot:
					print(slot)
					player_container.current_character.inventory[ServerData.itemTable[str(quest_data.questReq)].itemType][slot] = {'id': str(quest_data.questReq), 'q': 1}
					update_player_stats(player_container)
					rpc_id(player_id, "return_quest", -2)
					return
				else:
					print("inventory full")
					rpc_id(player_id, "return_quest", 1)
					return
			# search if item is in inventory -> replace if not there
			rpc_id(player_id, "return_quest", -1)
			print("item not used quest incomplete")
			return
			
	var reward_index = 0
	var inventory_index_list = []
	
	while reward_index <= quest_data.reward.size() - 2:
		if quest_data.reward[reward_index] != "experience" and quest_data.reward[reward_index] != 100000:
			var type = ServerData.itemTable[str(quest_data.reward[reward_index])].itemType
			var slot = null
			var inventory_index = 0
			
			for inventory_slot in player_container.current_character.inventory[type]:
				# if slot not empty
				if inventory_slot:
					#check if slot has same item id
					if inventory_slot.id == str(quest_data.reward[reward_index]):
						inventory_index_list.append(inventory_index)
						break
				# slot null
				else:
					if slot:
						if inventory_index < slot:
							slot = inventory_index
					else:
						slot = inventory_index
				inventory_index += 1
			
		reward_index += 2
	print("made it out inventory slot check")
	print(inventory_index_list)
	
	reward_index = 0
	var item_reward_index = 0
	while reward_index <= quest_data.reward.size() - 2:
		if quest_data.reward[reward_index] == "experience":
			player_container.experience(quest_data.reward[reward_index + 1])
		elif quest_data.reward[reward_index] == 100000:
			player_container.current_character.inventory["100000"] += quest_data.reward[reward_index + 1]
		else:
			var type = ServerData.itemTable[str(quest_data.reward[reward_index])].itemType
			if type == "equip":
				pass
				#player_container.current_character.inventory[str(type)][inventory_index_list[reward_index]] = {"id": str(quest_data.reward[reward_index]), "q": 1}
			else:
				if player_container.current_character.inventory[str(type)][inventory_index_list[reward_index]]:
					player_container.current_character.inventory[str(type)][inventory_index_list[reward_index]].q += 1
				else:
					 player_container.current_character.inventory[str(type)][inventory_index_list[reward_index]] = {"id": str(quest_data.reward[reward_index]), "q": 1}
		reward_index += 2
		
func update_quest_data(player_container) -> void:
	rpc_id(int(player_container.name), "send_quest_data", ServerData.quest_data[player_container.current_character.displayname])
	
