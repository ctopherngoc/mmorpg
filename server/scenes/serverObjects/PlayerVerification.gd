extends Node


onready var main_interface = get_parent()
onready var player_container_scene = preload("res://scenes/instances/PlayerContainer.tscn")

var awaiting_verification = {}

func start(player_id):
	"""
	authenticate token
	"""
	awaiting_verification[player_id] = {"Timestamp": OS.get_unix_time()}
	main_interface.fetch_token(player_id)
	
func verify(player_id, token, email):
	var temp_token = token['token'] + str(token['timestamp'])
	
	if email in ServerData.logged_emails:
		print("email in logged emails")
		awaiting_verification.erase(player_id)
		main_interface.expected_tokens.erase(temp_token)
		main_interface.already_logged_in(player_id, email)
	else:
		var token_verification = false
		while OS.get_unix_time() - token["timestamp"] <= 30:
			if main_interface.expected_tokens.has(temp_token):
				token_verification = true
				var player_container = create_player_container(player_id, token, email)
				yield(player_container, "completed")
				awaiting_verification.erase(player_id)
				main_interface.expected_tokens.erase(temp_token)
				break
			else:
				yield(get_tree().create_timer(2), "timeout")

		# add extra return argument for this for createokayercontainer == false
		main_interface.return_token_verification_results(player_id, token_verification)
		if token_verification == false:
			awaiting_verification.erase(player_id)
			main_interface.network.disconnect_peer(player_id)
		else:
			main_interface.get_player_data(player_id)

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
					main_interface.return_token_verification_results(key, false)
					main_interface.network.disconnect_peer(key)
	if(!awaiting_verification.empty()):
		print("Awaiting verification: %s" % str(awaiting_verification))
	
func create_player_container(player_id, token, email):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_node("/root/Server/World/CharacterSelect").add_child(new_player_container, true)
	ServerData.player_location[str(player_id)] = "/root/Server/World/CharacterSelect"
	var player_container = get_node("/root/Server/World/CharacterSelect/" + str(player_id))
	
	# establish logged-in email and player network-id: email connection for single log-in
	player_container.email = email
	ServerData.logged_emails.append(email)
	ServerData.player_id_emails[str(player_id)] = email
	
	player_container.db_info["token"] = token["token"]
	player_container.db_info["id"] = token["id"]
	
	var firebase_call = Firebase.get_document("users/%s" % player_container.db_info["id"], player_container.http, player_container.db_info["token"], player_container)
	yield(firebase_call, "completed")
	
	# if container.character_array is empty
	if player_container.characters.empty():
		pass
	else:
		var fill_player_container = fill_player_container(player_container)
		yield(fill_player_container, "completed")

# this assumes from conditionals that there are characters	
func fill_player_container(player_container):
	for character in player_container.characters:
		var firebase_call = Firebase.get_document("characters/%s" % character, player_container.http, player_container.db_info["token"], player_container)
		yield(firebase_call, "completed")
		
	print("fill_player_container completed")
		
	# temp player stats
	player_container.player_stats = ServerData.test_data.Stats
