extends Node


onready var main_interface = get_parent()
onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

var awaiting_verification = {}

func start(player_id):
	"""
	authenticate token
	"""
	awaiting_verification[player_id] = {"Timestamp": OS.get_unix_time()}
	main_interface.FetchToken(player_id)
	
func Verify(player_id, token):
	var temp_token = token['token'] + str(token['timestamp'])
	var token_verification = false
	while OS.get_unix_time() - token["timestamp"] <= 30:
		if main_interface.expected_tokens.has(temp_token):
			token_verification = true
			var playerContainer = CreatePlayerContainer(player_id, token)
			yield(playerContainer, "completed")
			# print('CreatePlayerContainer completed')
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(temp_token)
			break
		else:
			yield(get_tree().create_timer(2), "timeout")

	# add extra return argument for this for createokayercontainer == false
	main_interface.ReturnTokenVerificationResults(player_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)

func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key, false)
					main_interface.network.disconnect_peer(key)
	if(!awaiting_verification.empty()):
		print("Awaiting verification: %s" % str(awaiting_verification))
		#print(awaiting_verification)
	
func CreatePlayerContainer(player_id, token):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_node("/root/Server/World/CharacterSelect").add_child(new_player_container, true)
	ServerData.player_location[str(player_id)] = "/root/Server/World/CharacterSelect"
	#ServerData.player_location[str(player_id)] = "/root/Server/World/CharacterSelect/%s" % str(player_id)
	var playerContainer = get_node("/root/Server/World/CharacterSelect/" + str(player_id))
	
	playerContainer.db_info["token"] = token["token"]
	playerContainer.db_info["id"] = token["id"]
	
	var firebase_call = Firebase.get_document("users/%s" % playerContainer.db_info["id"], playerContainer.http, playerContainer.db_info["token"], playerContainer)
	yield(firebase_call, "completed")
	
	# if there are no characters
	# if container.character_array is empty
	if playerContainer.characters.empty():
		pass
	else:
		var fillPlayer = FillPlayerContainer(playerContainer)
		yield(fillPlayer, "completed")

# this assumes from conditionals that there are characters	
func FillPlayerContainer(playerContainer):
	for character in playerContainer.characters:
		var firebase_call = Firebase.get_document("characters/%s" % character, playerContainer.http, playerContainer.db_info["token"], playerContainer)#temp_array)
		yield(firebase_call, "completed")
		#print("FillPlayerContainer completed")
		
	# temp player stats
	playerContainer.player_stats = ServerData.test_data.Stats
