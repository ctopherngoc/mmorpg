extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2733
var max_players = 100

# example tokens added
var expected_tokens = []
onready var player_verification_process = get_node("PlayerVerification")
onready var character_creation_queue = []
#######################################################

#server start 
func _ready():
	
	# not used
	Firebase.httprequest = $HTTPRequest
	#
	
	start_server()

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _process(_delta):
	create_characters()

#######################################################
# Player connect
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	ServerData.player_location[str(player_id)] = 'connected'
	player_verification_process.start(player_id)

# when player disconnects
func _Peer_Disconnected(player_id):
	if ServerData.player_location[str(player_id)] == 'connected':
		ServerData.player_location.erase(str(player_id))
	else:
		# issue with failed log-in, stuck in log-in screen
		print(ServerData.player_location[str(player_id)])
		var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
		if not "CharacterSelect" in ServerData.player_location[str(player_id)]:
			Firebase.update_document("users/%s" % player_container.db_info["id"], player_container.http, player_container.db_info["token"], player_container)
			
			# no reason to update all characters since you only can make changes to current character
			# if there is an implementation where you can change characters without logging out
			# use the script below
			# has to update cur character before running this or else the two dictionaries won't match
			
			#for character in player_container.characters_info_list:
				#var firebase = Firebase.update_document("characters/%s" % str(character['displayname']), player_container.http2, player_container.db_info["token"], character)
				#yield(firebase, 'completed')
				
			# store current character to firebase
			var cur_character = player_container.current_character
			var firebase = Firebase.update_document("characters/%s" % str(cur_character['displayname']), player_container.http2, player_container.db_info["token"], cur_character)
			yield(firebase, 'completed')
		# uneeded else to confirm print
		else:
			print("dc in characterselect did not save")
		ServerData.player_location.erase(str(player_id))
		ServerData.player_state_collection.erase(player_id)
		ServerData.username_list.erase(player_id)
		ServerData.logged_emails.erase(ServerData.player_id_emails[str(player_id)])
		ServerData.username_list.erase(str(player_id))
		ServerData.player_id_emails.erase(str(player_id))
		player_container.timer.start()
		yield(player_container.timer, "timeout")
		rpc_id(0, "despawn_player", player_id)
		player_container.queue_free()
	print("User " + str(player_id) + " Disconnected")

func return_token_verification_results(player_id, result):
	if result != false:
		var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
		if player_container.characters.empty():
			rpc_id(player_id, "return_token_verification_results", result, [])
		else:
			rpc_id(player_id, "return_token_verification_results", result, player_container.characters_info_list)
			#load character data
			if result == true:
				pass
		#print(ServerData.player_location[str(player_id)])
	else:
		network.disconnect_peer(player_id)
		print("playercontainer empty probably big issue")

func fetch_token(player_id):
	print(get_tree().multiplayer.get_network_connected_peers())
	print('fetch token %s' % str(player_id))
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
				print(i)
				expected_tokens.remove(i)
		print("Expected Tokens:")
		print(expected_tokens)

remote func return_token(token, email):
	print("return token")
	var player_id = get_tree().get_rpc_sender_id()
	print('token returned running verify of %s' % str(player_id))
	player_verification_process.verify(player_id, token, email)


func already_logged_in(player_id, _email):
	rpc_id(player_id, "already_logged_in")
	network.disconnect_peer(player_id)
	
#######################################################
# client/server time sync
remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)
	
remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)

#######################################################
#character account
#create, ign checker, fetch player data, delete, spawn
func create_characters():
	if character_creation_queue.size() > 0:
		print("createCharacter found queue")
		#player_id, username, playerContainer, requester
		var character_array = character_creation_queue[0]
		character_creation_queue.remove(0)
		
		# firebase call to see if characer name is taken
		var firebase_call = Firebase.get_document("characters", character_array[2].http, character_array[2].db_info["token"], character_array)
		yield(firebase_call, 'completed')
		
		if character_array[1]["un"] in ServerData.username_list:
			print("%s already taken." % character_array[1])
			rpc_id(character_array[0], "returnfetchUsernames", character_array[3], false)
		else:
			#####################################################################################################################################
			#[player_id, char_dict, player_container, requester]
			print("%s not taken." % character_array[1])
			character_array[2].characters.append(character_array[1]["un"])
			print(character_array["un"])
			
			# update database account
			var firebase_call2 = Firebase.update_document("users/%s" % character_array[2].db_info["id"], character_array[2].http, character_array[2].db_info["token"], character_array[2])
			yield(firebase_call2, 'completed')
			var temp_player = ServerData.player_template.duplicate()
			temp_player['displayname'] = character_array[1]["un"]
			##################################################################
			#fill in character and top and bottom numbers
			##################################################################
			var firebase_call3 = Firebase.update_document("characters/%s" % character_array[1], character_array[2].http2, character_array[2].db_info["token"], temp_player)
			yield(firebase_call3, 'completed')

			character_array[2].characters_info_list.append(temp_player)

			# update client with new character
			rpc_id(character_array[0], "return_create_characters", character_array[3], character_array[2].characters_info_list)

remote func choose_character(requester, display_name: String):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	for character_dict in player_container.characters_info_list:
		if  display_name == character_dict['displayname']:
			player_container.current_character = character_dict
			##########
			"""Issue here fresh account no players
			invalid set index '234234324' (on base:array) with value type string
			"""
			ServerData.username_list[str(player_id)] = display_name
			break
	var map = player_container.current_character['lastmap']
	map = map.replace("res://scenes/maps/", "")
	map = map.replace(".tscn", "")
	# move user container to the map
	move_player_container(player_id, player_container, map, 'spawn')
	rpc_id(player_id, "return_choose_character", requester)

remote func fetch_player_stats():
	var player_id = get_tree().get_rpc_sender_id()
	var Maps = get_node("World/Maps")
	for i in Maps.get_children():
		for l in i.get_children():
			#print(l)
			if l.name == str(player_id):
				print(l.player_stats)

remote func fetch_usernames(requester, username):
	print("inside fetch username. Username: %s" % username)
	var player_id = get_tree().get_rpc_sender_id()
	print("player id: %s" % player_id)
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	var firebase_call = Firebase.get_document("characters", player_container.http, player_container.db_info["token"], player_container)
	yield(firebase_call, 'completed')
	print('username list')
	print(ServerData.username_list)
	if username in ServerData.username_list:
		print("%s already taken." % username)
		rpc_id(player_id, "return_fetch_usernames", requester, false)
	else:
		print("%s not taken." % username)
		# call create character function
		# update database,  server player container, send updated information to client
		rpc_id(player_id, "return_fetch_usernames", requester, true)
		pass

remote func create_character(requester, char_dict):
	print("create_character: Username: %s" % char_dict["un"])
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	
	"""
	not in dict
	var curr_lhand: int = 0
	var curr_hgear: int = 0
	var curr_eyewear: int = 0
	var curr_earring: int = 0
	var curr_glove: int = 0
	var curr_rhand: int = 0
	var bottom: int = 0
	"""
	character_creation_queue.append([player_id, char_dict, player_container, requester])

remote func fetch_characters():
# warning-ignore:unused_variable
	var player_id = get_tree().get_rpc_sender_id()
	print("In fetch characters")
	print("player location list")
	print(ServerData.player_location)

# warning-ignore:unused_argument
remote func delete_character(requester, display_name: String):
	""" 
		var characters = []
		var characters_info_list = []
	"""
	print("atempting to delete %s" % display_name)
	
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	
	# find index from character array delete index in characters and charaters info list
	var index = player_container.characters.find(display_name)
	player_container.characters.remove(index)
	player_container.characters_info_list.remove(index)
	
	var firebase_call = Firebase.update_document("users/%s" % player_container.db_info["id"], player_container.http, player_container.db_info["token"], player_container)
	yield(firebase_call, "completed")
	firebase_call = Firebase.delete_document("characters/%s" % display_name, player_container.http2, player_container.db_info["token"])
	yield(firebase_call, "completed")
	rpc_id(player_id, "return_delete_character", player_container.characters_info_list, requester)

func despawnPlayer(player_id):
	rpc_unreliable_id(0, "receive_despawn_player", player_id)

# arugment is a player container
func update_player_stats(player_container):
	print('updating player stats for client')
	rpc_id(int(player_container.name), "update_player_stats", player_container.current_character)

#######################################################
# Character containers/information 
func move_player_container(player_id, player_container, map_id, portal_position):
	var old_parent = get_node(str(ServerData.player_location[str(player_id)]))
	var new_parent = get_node("/root/Server/World/Maps/%s/YSort/Players" % map_id)

	old_parent.remove_child(player_container)
	new_parent.add_child(player_container)

	ServerData.player_location[str(player_id)] = "/root/Server/World/Maps/" + str(map_id) + "/YSort/Players"
	var player = get_node("/root/Server/World/Maps/" + str(map_id) + "/YSort/Players/" + str(player_id))
	var map_node = get_node("/root/Server/World/Maps/%s" % map_id)
	var map_position = map_node.get_global_position()

	if typeof(portal_position) == TYPE_STRING:
		var new_location = Vector2((map_position.x + map_node.spawn_position.x), (map_position.y + map_node.spawn_position.y))
		player.position = new_location
	else:
		print(str(portal_position))
		var new_location = Vector2((map_position.x + portal_position.x), (map_position.y + portal_position.y))
		player.position = new_location
	player_container.cur_position = player.position
	player_container.start_idle_timer()

func get_player_data(player_id):
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	# warning-ignore:unused_variable
	var character_count = player_container.db_info

remote func portal(portal_id):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	# validate
	print(portal_id)
	var portal = ServerData.player_location[str(player_id)].replace("YSort/Players", "MapObjects/%s" % portal_id)
	# get portal node
	get_node(portal).over_lapping_bodies(player_id)
	rpc_id(player_id, "return_portal", player_id)
	# move player container

	#get nextmap name
	var map_id = get_node(ServerData.player_location[str(player_id)].replace("YSort/Players", "")).map_id
	var next_map = ServerData.portal_data[map_id][portal_id]['map']
	# get mapname, move user container to the map
	print("move character container to %s" % next_map)
	print(map_id, portal_id)
	move_player_container(player_id, player_container, next_map, ServerData.portal_data[map_id][portal_id]['spawn'])
	print('update current character last map')
	player_container.current_character['lastmap'] = next_map

	update_player_stats(player_container)

	print("update character list last map")
	for character in player_container.characters_info_list:
		if character['displayname'] == player_container.current_character['displayname']:
			character['lastmap'] = player_container.current_character['lastmap']

	# send rpc to client to change map
	print('sending signal to client to change map')
	rpc_id(player_id, "change_map", next_map, ServerData.portal_data[map_id][portal_id]['spawn'])
	# put some where if world state != current map ignore
#######################################################

#world states
remote func received_player_state(player_state):
	#print(player_state["P"])
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))

	# change damage box left and right
	if player_state["A"]["d"] == 1:
		get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id) + "/do_damage").scale.x = 1
	elif player_state["A"]["d"] == 0:
		get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id) + "/do_damage").scale.x = -1

	var map_node = get_node(ServerData.player_location[str(player_id)])
	var server_position = map_node.get_global_position()
	var client_position = player_state["P"]
	var final_position = Vector2((server_position.x + client_position.x), (server_position.y + client_position.y))

	player_state["U"] = ServerData.username_list[str(player_id)]
	#print(player_state["P"])
	# update player state
	# move to player container
	if ServerData.player_state_collection.has(player_id):
		if ServerData.player_state_collection[player_id]["T"] < player_state["T"]:
			player_container.global_position = final_position
			ServerData.player_state_collection[player_id] = player_state
	# just logged in add player state
	else:
		 ServerData.player_state_collection[player_id] = player_state

func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_world_state", world_state)

###############################################################################
# server combat functions
remote func attack(attack_time):
	var player_id = get_tree().get_rpc_sender_id()
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	player_container.attack()
	#print(str(player_id) + " attacking")
	rpc_id(0, "receive_attack", player_id, attack_time)
#######################################################
