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
var stats
# example tokens added
var expected_tokens = []
onready var player_verification_process = get_node("PlayerVerification")
onready var character_creation_queue = []
const username: String = "server@server.com"
const password: String = "server123"

#######################################################
# server netcode
#server start 
func _ready() -> void:
	Firebase.httprequest = $HTTPRequest
	start_server()
	Firebase.get_data(username, password)

func start_server() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _process(_delta: float) -> void:
	create_characters()
	#print(typeof(ServerData.characters_data.scrubaduck.inventory.equipment[0].magic))

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
			var firebase = Firebase.update_document("characters/%s" % str(cur_character['displayname']), player_container.http2, player_container.db_info["token"], cur_character)
			yield(firebase, 'completed')
		else:
			print("dc in characterselect did not save")
		_Server_Data_Remove_Player(player_id)
		player_container.timer.start()
		yield(player_container.timer, "timeout")
		rpc_id(0, "despawn_player", player_id)
		player_container.queue_free()
	print("User " + str(player_id) + " Disconnected")

func _Server_Data_Remove_Player(player_id: int) -> void:
	ServerData.player_location.erase(str(player_id))
	ServerData.player_state_collection.erase(player_id)
	ServerData.logged_emails.erase(ServerData.player_id_emails[str(player_id)])
	ServerData.player_id_emails.erase(str(player_id))
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
	#print(get_tree().multiplayer.get_network_connected_peers())
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
				#print(i)
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
		
		if character_array[1]["un"] in ServerData.characters_data.keys():
			print("%s already taken." % character_array[1])
			rpc_id(character_array[0], "returnfetchUsernames", character_array[3], false)
		else:
			#[player_id, char_dict, player_container, requester]
			character_array[2].characters.append(character_array[1]["un"])
			var new_char = character_array[1]
			var temp_player = _Server_New_Character(new_char)
			print(temp_player)

			print("creating character")
			var firebase_call2 = Firebase.update_document("characters/%s" % temp_player["displayname"], character_array[2].http2, character_array[2].db_info["token"], temp_player)
			yield(firebase_call2, 'completed')
			
			ServerData.characters_data[temp_player.displayname] = temp_player

			var firebase_call3 = Firebase.update_document("users/%s" % character_array[2].db_info["id"], character_array[2].http, character_array[2].db_info["token"], character_array[2])
			yield(firebase_call3, 'completed')
			character_array[2].characters_info_list.append(temp_player)

			# update client with new character
			rpc_id(character_array[0], "return_create_characters", character_array[3], character_array[2].characters_info_list)

func _Server_New_Character(new_char: Dictionary):
	var temp_player = ServerData.static_data.player_template.duplicate(true)
	print("temp_player in _server_new_char: %s: " % temp_player)
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
	#print(new_char["o"])
	if new_char["o"] == 0:
		equips["top"] = ServerData.static_data.starter_equips[0][0]
		equips["bottom"] = ServerData.static_data.starter_equips[0][1]
	elif new_char["o"] == 1:
		equips["top"] = ServerData.static_data.starter_equips[1][0]
		equips["bottom"] = ServerData.static_data.starter_equips[1][1]
	else:
		equips["top"] = ServerData.static_data.starter_equips[2][0]
		equips["bottom"] = ServerData.static_data.starter_equips[2][1]
		
	############################################################################
	#temp add weapon
	equips.rweapon = {"accuracy":0, "attack":15, "avoidability":0, "bossPercent":5, "critRate":0, "damagePercent":0, "defense":0, "dexterity":4, "id":"200001", "job":0, "jumpSpeed":0, "luck":5, "magic":0, "magicDefense":0, "maxHealth":0, "maxMana":0, "movementSpeed":0, "name":"Training Sword", "slot":7, "attackSpeed":5, "strength":5, "type":"1h_sword", "wisdom":5, "uniqueID": str(Global.rng.randi_range(1, 1000000000))}
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

	temp_dict = player_container.current_character.equipment
	player_container.sprite.append(str(temp_dict.headgear))
	player_container.sprite.append(str(temp_dict.top))
	player_container.sprite.append(str(temp_dict.bottom))
	player_container.sprite.append(str(temp_dict.rweapon.id))
	player_container.sprite.append(str(temp_dict.lweapon))
	player_container.sprite.append(str(temp_dict.eyeacc))
	player_container.sprite.append(str(temp_dict.earring))
	player_container.sprite.append(str(temp_dict.faceacc))
	player_container.sprite.append(str(temp_dict.glove))
	player_container.sprite.append(str(temp_dict.tattoo))
	
	# move user container to the map
	move_player_container(player_id, player_container, map, 'spawn')
	player_container.load_player_stats()
	player_container.start_idle_timer()
	Global.calculate_stats(player_container.current_character)
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

	var firebase_call = Firebase.update_document("users/%s" % player_container.db_info["id"], player_container.http, player_container.db_info["token"], player_container)
	yield(firebase_call, "completed")
	# warning-ignore:void_assignment
	var firebase_call2 = Firebase.delete_document("characters/%s" % display_name, player_container.http2, player_container.db_info["token"])
	yield(firebase_call2, "completed")
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

	if typeof(position) == TYPE_STRING:
		position = Vector2(map_node.spawn_position.x, map_node.spawn_position.y)

	player.position = position

func get_player_data(player_id):
	var player_container = _Server_Get_Player_Container(player_id)
	# warning-ignore:unused_variable
	var character_count = player_container.db_info

remote func portal(portal_id):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# validate
	#print(portal_id)
	var portal = ServerData.player_location[str(player_id)].replace("YSort/Players", "MapObjects/%s" % portal_id)
	# get portal node
	get_node(portal).over_lapping_bodies(player_id)
	rpc_id(player_id, "return_portal", player_id)

	#get nextmap name
	var map_id = get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).map_id
	var next_map = ServerData.portal_data[map_id][portal_id]['map']
	# get mapname, move user container to the map
	#print("move character container to %s" % next_map)
	move_player_container(player_id, player_container, next_map, ServerData.portal_data[map_id][portal_id]['spawn'])
	#print('update current character last map')
	player_container.current_character['map'] = next_map

	update_player_stats(player_container)

	#print("update character list last map")
	for character in player_container.characters_info_list:
		if character['displayname'] == player_container.current_character['displayname']:
			character['map'] = player_container.current_character['map']

	# send rpc to client to change map
	#print('sending signal to client to change map')
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
	"""
	reduce packet size
	
	#######should be renamed to send_map_state
	altered to send map chunks to each player in the map
	"""
	for player in player_list:
		rpc_unreliable_id(int(player), "receive_world_state", map_state)

###############################################################################
# server combat functions
remote func receive_attack(move_id):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# basic attack
	if move_id == 0:
		player_container.attack(0)
	#uses skill
	else:
		if move_id in ServerData.class_skills[player_container.current_character.stats.class]:
			if player_container.current_character.equipment.rweapon in ServerData.class_dict[player_container.current_character.stats.class]["Weapon"]:
				if player_container.skill_id_cd:
					print("skill on cd")
				if player_container.current_character.stats.mana > 0:
					if move_id.type == "buff":
						print("playey use buff ", move_id)
						#player_container.buff(move_id)
					# move == attack
					else:
						if ServerData.class_dict[player_container.current_character.stats.class]["Range"] == 1 && ServerData.class_dict[player_container.current_character.equipment.ammo["quantity"]] == 0:
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
	#print(player_container.current_character.inventory[tab[inv_data[0]]])
	# update client
	update_player_stats(player_container)

func _unhandled_input(event):
	if event is InputEventKey:if event.pressed and event.scancode == KEY_SPACE:
			move_item([1,0,1])
			#Global.dropSpawn("100001", Vector2(414, -69), {"100000": 5}, "PlayerContainer")
		
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
	print("in use_item")
	# get player container
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	# if item in inventory
	print(item)
	if item[0] == player_container.current_character.inventory.use[item[1]].id:
		# if item count > 0 decrement
		if player_container.current_character.inventory.use[item[1]].q > 0:
			player_container.current_character.inventory.use[item[1]].q -= 1
			# get item type and amount
			var quantity = ServerData.itemTable[item[0]].useAmount
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
	print("in add_stat")
	# get player container
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = _Server_Get_Player_Container(player_id)
	
	if player_container.current_character.stats.base.sp > 0:
		player_container.current_character.stats.base.sp -= 1
		if stat == "s":
			print("%s incrase strength" % player_id)
			player_container.current_character.stats.base.strength += 1
		elif stat == "w":
			player_container.current_character.stats.base.wisdom += 1
			print("%s incrase wisdom" % player_id)
		elif stat == "d":
			player_container.current_character.stats.base.dexterity += 1
			print("%s incrase dexterity" % player_id)
		else:
			player_container.current_character.stats.base.luck += 1
			print("%s incrase luck" % player_id)
		update_player_stats(player_container)
		send_client_notification(player_id, "added 1 to %s" % stat)
	else:
		send_client_notification(player_id, "not enough sp")
######################################################################
# test buttons
func _on_Button_pressed():
	$Test/PlayerContainer.attack(0)

# function takes current_character
func _on_Button2_pressed():
	Global.calculate_stats($Test/PlayerContainer.current_character)
func _on_Button3_pressed():
#	print("dropping potion")
#	Global.dropSpawn("100001", Vector2(231, -405), {"300000": 1}, "PlayerContainer")
#	print("testcase 1")
#	print("dropping leather pants")
	var bottom = {"500003": 1, "accuracy":0, "attack":15, "avoidability":0, "bossPercent":5, "critRate":0, "damagePercent":0, "defense":0, "dexterity":4, "job":0, "jumpSpeed":0, "luck":5, "magic":0, "magicDefense":0, "maxHealth":0, "maxMana":0, "movementSpeed":0, "name":"Leather Bottom", "slot":7, "speed":5, "strength":5, "type":"bottom", "wisdom":5, "uniqueID": 100000000}
	Global.dropSpawn("100001",  Vector2(231, -405), {"500003": bottom}, "testing123")
	#print("dropping  200 gold")
	#Global.dropSpawn("100001",  Vector2(231, -405), {"100000": 200}, "testing123")
#	print("cuurent gold: %s" % Global.testplayer.current_character.inventory["100000"])
	
	#print("setting testplayer max gold")
	#Global.testplayer.current_character.inventory["100000"] = Global.max_int -10
	#print("cuurent gold: %s" % Global.testplayer.current_character.inventory["100000"])

func _on_Button4_pressed():
	print("testing loot request")
	var test_player = $Test/PlayerContainer
	test_player.loot_request()
	#print("cuurent gold: %s" % Global.testplayer.current_character.inventory["100000"])


func _on_Button5_pressed():
#	print("firebase button press")
#	var server_dict = ServerData.characters_data["testing222"].duplicate(true)
#	server_dict.inventory.use[3] = {"id": "300001", "q": 123}
	#server_dict.inventory.use[3] = null
	#server_dict.equipment.rweapon = {"accuracy":0, "type": "1h_sword", "id": 10000}
	#server_dict.equipment.rweapon =  {"accuracy":0, "attack":15, "avoidability":0, "bossPercent":5, "critRate":0, "damagePercent":0, "defense":0, "dexterity":4, "id":"200001", "job":0, "jumpSpeed":0, "luck":5, "magic":0, "magicDefense":0, "maxHealth":0, "maxMana":0, "movementSpeed":0, "name":"Training Sword", "slot":7, "speed":5, "strength":5, "type":"1h_sword", "wisdom":5, "uniqueID": 100000000}
	#server_dict.equipment.rweapon = ServerData.characters_data["duma123"].equipment.rweapon
	#server_dict.equipment.top = {"id": 500000}
	#save("res://save.json",fb_data)
	#Firebase.test_update_document("characters/testing222", server_dict)
	#print(ServerData.characters_data["testing222"]["inventory"]["equipment"][0])
	#var actual_equip = ServerData.characters_data["testing222"]["inventory"]["equipment"][0]
	#var server_dict =  {"owner": "testing222", "accuracy":0, "attack":15, "avoidability":0, "bossPercent":5, "critRate":0, "damagePercent":0, "defense":0, "dexterity":4, "id":"200001", "job":0, "jumpSpeed":0, "luck":5, "magic":0, "magicDefense":0, "maxHealth":0, "maxMana":0, "movementSpeed":0, "name":"Training Sword", "slot":7, "movementSpeed":5, "strength":5, "type":"1h_sword", "wisdom":5, "uniqueID": 10000002}
	#print(server_dict)
	var server_dict =  {"owner": "testing222", "id":"200001", "uniqueID": "10000002", "name": "test_item", "type": "1h_sword"}
	Firebase.test_update_document("items/%s" % str(server_dict.id + str(server_dict.uniqueID)), server_dict)
	
func save(var path : String, var thing_to_save):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(JSON.print(thing_to_save, "\t"))
	file.close()

####################################################################################

remote func send_chat(text: String, chat_type: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	print("%s said %s" % [player_id, text])
	var player_container = _Server_Get_Player_Container(player_id)
	ServerData.chat_logs.append({"email": player_container.email, "ign": player_container.current_character.displayname, "time": OS.get_unix_time(), "msg": text, "chatType": chat_type})
	# in map
	if chat_type == 0:
		var map_player_list = get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).players
		for player in map_player_list:
			rpc_id(int(player.name), "update_messages", player_container.current_character.displayname, text, chat_type)
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
	
		
