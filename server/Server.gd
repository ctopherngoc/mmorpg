extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1000
var max_players = 100

# example tokens added
var expected_tokens = []
#var expected_tokens = ["eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg3NTNiYmFiM2U4YzBmZjdjN2ZiNzg0ZWM5MmY5ODk3YjVjZDkwN2QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZ29kb3Rwcm9qZWN0LWVmMjI0IiwiYXVkIjoiZ29kb3Rwcm9qZWN0LWVmMjI0IiwiYXV0aF90aW1lIjoxNjcyNTI0NDQ5LCJ1c2VyX2lkIjoiTEUwTEFTbnRZblNvSDhzaW1ES1FqejY5WVJEMiIsInN1YiI6IkxFMExBU250WW5Tb0g4c2ltREtRano2OVlSRDIiLCJpYXQiOjE2NzI1MjQ0NDksImV4cCI6MTY3MjUyODA0OSwiZW1haWwiOiJjdG9waGVybmdvY0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiY3RvcGhlcm5nb2NAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.En_bdnGwiDBbruv-jGs5A9VRsQlqm85Evjfs8egKz31MBhxhQgPsn1k5Xq9LGfgJyRcl_Q24b6SSawnR1LkBsdLd-IuS3xzlGrSzoq7eIGb1-I1TkegSSJCz-LL2vqaTCmmBK6NmhK_Q7rWzBqUs9E70Ca92m85ok3wUf8hwkMcw97O78lwSk27yXU2KJU4YoijZi9-vZ8084670QOGwXDZp3qspUD0V9IFGEYIovjkaH2ZbnQFFpKP5iPlsheaqEI-5SY6POzWkQoIkTQ5ITK1oAbsECHoVd2h5a8FJ6kjC9QEqBOnxKifxpujqHvuTOftWuFbpAs-OI2D2N4kzhg1678527570",
#"eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg3NTNiYmFiM2U4YzBmZjdjN2ZiNzg0ZWM5MmY5ODk3YjVjZDkwN2QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZ29kb3Rwcm9qZWN0LWVmMjI0IiwiYXVkIjoiZ29kb3Rwcm9qZWN0LWVmMjI0IiwiYXV0aF90aW1lIjoxNjcyNTI0NDQ5LCJ1c2VyX2lkIjoiTEUwTEFTbnRZblNvSDhzaW1ES1FqejY5WVJEMiIsInN1YiI6IkxFMExBU250WW5Tb0g4c2ltREtRano2OVlSRDIiLCJpYXQiOjE2NzI1MjQ0NDksImV4cCI6MTY3MjUyODA0OSwiZW1haWwiOiJjdG9waGVybmdvY0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiY3RvcGhlcm5nb2NAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.En_bdnGwiDBbruv-jGs5A9VRsQlqm85Evjfs8egKz31MBhxhQgPsn1k5Xq9LGfgJyRcl_Q24b6SSawnR1LkBsdLd-IuS3xzlGrSzoq7eIGb1-I1TkegSSJCz-LL2vqaTCmmBK6NmhK_Q7rWzBqUs9E70Ca92m85ok3wUf8hwkMcw97O78lwSk27yXU2KJU4YoijZi9-vZ8084670QOGwXDZp3qspUD0V9IFGEYIovjkaH2ZbnQFFpKP5iPlsheaqEI-5SY6POzWkQoIkTQ5ITK1oAbsECHoVd2h5a8FJ6kjC9QEqBOnxKifxpujqHvuTOftWuFbpAs-OI2D2N4kzhg1572527570"]
onready var player_verification_process = get_node("PlayerVerification")
#onready var cobat_functions = get_node("Combat")

onready var character_creation_queue = []

#######################################################
#server start 
func _ready():
	
	# not used
	Firebase.httprequest = $HTTPRequest
	#
	
	StartServer()

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _process(_delta):
	createCharacters()

#######################################################
# Player connect
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	player_verification_process.start(player_id)


##E 0:00:43.596   get_node: (Node not found: "/root/Server/World/Maps/BaseLevel/Ysort/Players/527585974" (absolute path attempted from "/root/Server").)
# when player disconnects
func _Peer_Disconnected(player_id):
	print(ServerData.player_location[str(player_id)])
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	if not "CharacterSelect" in ServerData.player_location[str(player_id)]:
		Firebase.update_document("users/%s" % playerContainer.db_info["id"], playerContainer.http, playerContainer.db_info["token"], playerContainer)
		print("firebase update_document before peer disconnect")
		for character in playerContainer.characters_info_list:
			var firebase = Firebase.update_document("characters/%s" % str(character['displayname']), playerContainer.http2, playerContainer.db_info["token"], character)
			yield(firebase, 'completed')
			
	# uneeded else to confirm print
	else:
		print("dc in characterselect did not save")
	ServerData.player_location.erase(str(player_id))
	ServerData.player_state_collection.erase(player_id)
	ServerData.username_list.erase(player_id)
	playerContainer.timer.start()
	yield(playerContainer.timer, "timeout")
	rpc_id(0, "DespawnPlayer", player_id)
	playerContainer.queue_free()
	print("User " + str(player_id) + " Disconnected")
	
func ReturnTokenVerificationResults(player_id, result):
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	#print(playerContainer.characters)
	
	if playerContainer.characters.empty():
		rpc_id(player_id, "ReturnTokenVerificationResults", result, [])
	else:
		rpc_id(player_id, "ReturnTokenVerificationResults", result, playerContainer.characters_info_list)
		#load character data
		if result == true:
			pass
	#print(ServerData.player_location[str(player_id)])

func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			var token_time = int(expected_tokens[i].right(936))
			# deletes tokens older or future
			if current_time - token_time >= 30 or current_time - token_time < 0:
#			if current_time - expected_tokens[i]["timestamp"] >= 30:
				print(i)
				expected_tokens.remove(i)
		print("Expected Tokens:")
		print(expected_tokens)

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)
	getPlayerInfo(player_id)

	#		rpc_id(0, "SpawnNewPlayer", player_id, Vector2(100, -250))

#######################################################
# client/server time sync
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)

#######################################################
#character account
#create, ign checker, fetch player data, delete, spawn
func createCharacters():
	if character_creation_queue.size() > 0:
		print("createCharacter found queue")
		#player_id, username, playerContainer, requester
		var temp_arr = character_creation_queue[0]
		character_creation_queue.remove(0)
		
		var firebase_call = Firebase.get_document("characters", temp_arr[2].http, temp_arr[2].db_info["token"], temp_arr)
		yield(firebase_call, 'completed')
		
		if temp_arr[1] in ServerData.username_list:
			print("%s already taken." % temp_arr[1])
			rpc_id(temp_arr[0], "returnfetchUsernames", temp_arr[3], false)
		else:
			
			print("%s not taken." % temp_arr[1])
			
			temp_arr[2].characters.append(temp_arr[1])
			print(temp_arr)
			
			var firebase_call2 = Firebase.update_document("users/%s" % temp_arr[2].db_info["id"], temp_arr[2].http, temp_arr[2].db_info["token"], temp_arr[2])
			yield(firebase_call2, 'completed')
			
			var server_temp_player = ServerData.playerTemplate.duplicate()
			server_temp_player['displayname'] = temp_arr[1]
			var firebase_call3 = Firebase.update_document("characters/%s" % temp_arr[1], temp_arr[2].http2, temp_arr[2].db_info["token"], server_temp_player)
			yield(firebase_call3, 'completed')
			
			temp_arr[2].characters_info_list.append(server_temp_player)
			
			# update client with new character
			rpc_id(temp_arr[0], "returnCreateCharacters", temp_arr[3], temp_arr[2].characters_info_list)

remote func ChooseCharacter(requester, charactername: String):
	#print("Choosing character: %s" % charactername)
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	for character_dict in playerContainer.characters_info_list:
		if  charactername == character_dict['displayname']:
			playerContainer.current_character = character_dict
			ServerData.username_list[str(player_id)] = charactername
			break
	#print("current character")
	#print(playerContainer.current_character)
	var map = playerContainer.current_character['lastmap']
	map = map.replace("res://scenes/maps/", "")
	map = map.replace(".tscn", "")
	# move user container to the map
	MovePlayerContainer(player_id, playerContainer, map)
	rpc_id(player_id, "ReturnChooseCharacter", requester)
	#rpc_id(0, "SpawnNewPlayer", player_id, map)

remote func FetchPlayerStats():
	var player_id = get_tree().get_rpc_sender_id()
	var Maps = get_node("World/Maps")
	for i in Maps.get_children():
		for l in i.get_children():
			#print(l)
			if l.name == str(player_id):
				print(l.player_stats)
	#print(player_node)
	#var player_stats = player_node.player_stats
	#rpc_id(player_id, "ReturnPlayerStats", player_stats)

remote func fetchUsernames(requester, username):
	print("inside fetch username. Username: %s" % username)
	var player_id = get_tree().get_rpc_sender_id()
	print("player id: %s" % player_id)
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	print(playerContainer)
	var firebase_call = Firebase.get_document("characters", playerContainer.http, playerContainer.db_info["token"], playerContainer)
	yield(firebase_call, 'completed')
	print("outside of firebase call")
	print('username list')
	print(ServerData.username_list)
	if username in ServerData.username_list:
		print("%s already taken." % username)
		rpc_id(player_id, "returnfetchUsernames", requester, false)
	else:
		print("%s not taken." % username)
		# call create character function
		# update database,  server player container, send updated information to client
		rpc_id(player_id, "returnfetchUsernames", requester, true)
		pass

remote func createCharacter(requester, username):
	print("createCharacter: Username: %s" % username)
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	character_creation_queue.append([player_id, username, playerContainer, requester])

remote func FetchCharacters():
# warning-ignore:unused_variable
	var player_id = get_tree().get_rpc_sender_id()
	print("In FetchCharacters")
	print("player location list")
	print(ServerData.player_location)

# warning-ignore:unused_argument
remote func deleteCharacter(requester, displayname: String):
	""" 
		var characters = []
		var characters_info_list = []
	"""
	print("atempting to delete %s" % displayname)
	
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % player_id)
	
	# find index from character array delete index in characters and charaters info list
	var index = playerContainer.characters.find(displayname)
	playerContainer.characters.remove(index)
	playerContainer.characters_info_list.remove(index)
	
	var firebase_call = Firebase.update_document("users/%s" % playerContainer.db_info["id"], playerContainer.http, playerContainer.db_info["token"], playerContainer)
	yield(firebase_call, "completed")
	firebase_call = Firebase.delete_document("characters/%s" % displayname, playerContainer.http2, playerContainer.db_info["token"])
	yield(firebase_call, "completed")
	rpc_id(player_id, "returnDeleteCharacter", playerContainer.characters_info_list, requester)
	
remote func SpawnCharacter(requester, displayname: String):
	# get node
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)])
	# set selected player
	playerContainer.current_character = playerContainer.characters_info_list[displayname]
	var map = playerContainer.current_character["lastmap"]
	map = map.replace("res://scenes/maps/", "")
	map = map.replace(".tscn", "")
	# spawn selected player in world
	MovePlayerContainer(player_id, playerContainer, map)
	# send rpc to spawn characters in other worlds
	#rpc_id(0, "SpawnNewPlayer", player_id, map)

func despawnPlayer(player_id):
	rpc_unreliable_id(0, "ReceiveDespawnPlayer", player_id)

func UpdatePlayerStats(player):
	rpc_id(int(player.name), "UpdatePlayerStats", player.current_character)
	pass
#######################################################
# Character containers/information 
func MovePlayerContainer(player_id, playerContainer, map):
	var old_parent = get_node(str(ServerData.player_location[str(player_id)]))
	var new_parent = get_node("/root/Server/World/Maps/%s/YSort/Players" % map)
	
	old_parent.remove_child(playerContainer)
	new_parent.add_child(playerContainer)
	
	ServerData.player_location[str(player_id)] = "/root/Server/World/Maps/" + str(map) + "/YSort/Players"
	var player = get_node("/root/Server/World/Maps/" + str(map) + "/YSort/Players/" + str(player_id))
	var mapNode = get_node("/root/Server/World/Maps/%s" % map)
	var mapPosition = mapNode.get_global_position()
	var new_location = Vector2((mapPosition.x + mapNode.spawn_position.x), (mapPosition.y + mapNode.spawn_position.y))
	player.position = new_location

func getPlayerInfo(player_id):
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	# warning-ignore:unused_variable
	var character_count = playerContainer.db_info

remote func Portal(portalName):
	var player_id = get_tree().get_rpc_sender_id()
	# validate
	var portal = ServerData.player_location[str(player_id)].replace("YSort/Players", "MapObjects/%s" % portalName)
	# get portal node
	get_node(portal).overLappingBodies(player_id)
	rpc_id(player_id, "ReturnPortal", player_id)
	
#######################################################
#world states
remote func ReceivedPlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	
	# change damage box left and right
	if player_state["A"]["d"] == 1:
		get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id) + "/do_damage").scale.x = 1
	elif player_state["A"]["d"] == 0:
		get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id) + "/do_damage").scale.x = -1
	# update player client location to server global position
	##################
	#move to playercontainer.procesmovement
	var mapNode = get_node(ServerData.player_location[str(player_id)])
	var mapPosition = mapNode.get_global_position()
	var clientPosition = player_state["P"]
	player_state["P"] = Vector2((mapPosition.x + clientPosition.x), (mapPosition.y + clientPosition.y))
	#################################
	player_state["U"] = ServerData.username_list[str(player_id)]
	
	# update player state
	# move to player container
	if ServerData.player_state_collection.has(player_id):
		if ServerData.player_state_collection[player_id]["T"] < player_state["T"]:
			playerContainer.global_position = player_state["P"]
			ServerData.player_state_collection[player_id] = player_state

	# just logged in add player state
	else:
		 ServerData.player_state_collection[player_id] = player_state

func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)

###############################################################################
# server combat functions
remote func Attack(attack_time):
	var player_id = get_tree().get_rpc_sender_id()
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	playerContainer.Attack()
	#print(str(player_id) + " attacking")
	rpc_id(0, "ReceiveAttack", player_id, attack_time)

#######################################################
