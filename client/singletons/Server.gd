extends Node
var port = 2733
var token
var email
var network = null

var login_status = 0

var latency_array = []
var latency = 0 
var delta_latency = 0
var client_clock = 0
var decimal_collector = 0
var server_status = false
var timer = Timer.new()

func _ready():
	timer.wait_time = 0.5
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

######################################################################
# Server connection/latency functions
func connect_to_server():
	network = NetworkedMultiplayerENet.new()
	network.create_client(Global.ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_on_server_disconnect")

func _on_connection_failed():
	print("Failed to connected")

func _on_connection_succeeded():
	server_status = true
	print("Successfully connected")
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	timer.start()

func _on_server_disconnect():
	server_status = false
	Global.world_state_buffer.clear()
	timer.stop()
	print("server disconnected")
	
	if login_status == 1:
		SceneHandler.change_scene("login")
		login_status = 0

func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())

remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size() - latency)
		latency = total_latency / latency_array.size()
		latency_array.clear()
#################################################################
# Character functions

func check_usernames(requester, username):
	rpc_id(1, "fetch_usernames", requester, username)

remote func return_fetch_usernames(requester, results):
	print("server username check: %s" % str(results))
	instance_from_id(requester).username_check_results(results)

func create_character(requester, char_dict):
	print("attempting to create character: %s" % char_dict["un"])
	rpc_id(1, "create_character", requester, char_dict)

remote func return_create_characters(requester, character_array: Array):
	print('return_create_characters')
	Global.character_list = character_array
	instance_from_id(requester).created_character()

func delete_character(requester, username):
	print("attempting to delete character: %s" % username)
	rpc_id(1, "delete_character", requester, username)

remote func return_delete_character(player_array, requester):
	Global.character_list = player_array
	instance_from_id(requester).populate_info()
	instance_from_id(requester).deleted_character()
	print("deleted character")

func choose_character(requester, player_name):
	rpc_id(1, "choose_character", requester, player_name)

# warning-ignore:unused_argument
remote func return_choose_character(requester):
	print("server.gd: return_choose_character")
	SceneHandler.change_scene(Global.player['map']) 
	#instance_from_id(requester).load_world()

func fetch_player_stats():
	rpc_id(1, "fetch_player_stats")

##############################################################################
# Authentication
remote func fetch_token():
	rpc_id(1, "return_token", token, email)

remote func return_token_verification_results(result, array):
	print("server.gd: return_token_verification_results")
	if result == true:
		print("token verified")
		Global.character_list = array
		fetch_player_stats()
		login_status = 1
		SceneHandler.change_scene("characterSelect")
	else:
		print("token unverified")
		var login_scene = get_tree().get_current_scene()
		login_scene.login_button.disabled = false
		login_scene.notification.text = "login failed, please try again"

remote func already_logged_in():
	print("server.gd: already_logged_in")
	var login_scene = get_tree().get_current_scene()
	login_scene.login_button.disabled = false
	login_scene.notification.text = "Account already logged in"
	timer.stop()

#################################################################################
# Player functions
remote func despawn_player(player_id):
	print("server.gd: despawn player")
	var other_players = get_node("/root/currentScene/OtherPlayers")
	for player in other_players.get_children():
		print(str(player) + str(player_id))
		if player.name == str(player_id):
			print("matches despawning char")
			player.queue_free()

func send_player_state(player_state):
	rpc_unreliable_id(1, "received_player_state", player_state)

remote func receive_world_state(world_state):
	if Global.current_map == "":
		pass
	else:	
		Global.update_world_state(world_state)

remote func receive_despawn_player(player_id):
	Global.despawn_player(player_id)
	
func send_attack():
	print("server.gd: send_attack")
	rpc_id(1, "attack", Server.client_clock)
	
remote func receive_attack(player_id, attack_time):
	print("server.gd: recieve_attack")
	if player_id == get_tree().get_network_unique_id():
		print("self attack: pass")
	elif get_node("/root/currentScene/OtherPlayers").has_node(str(player_id)):
		print(str(player_id) + " attack")
		var player = get_node("/root/currentScene/OtherPlayers/%s" % player_id)
		player.attack_dict[attack_time] = {"A": "stab"}
	else:
		pass

remote func update_player_stats(player_stats):
	#print('server.gd: remote update_player_stats')
	#print(player_stats)

	for character in Global.character_list:
		if character["displayname"] == player_stats["displayname"]:
			character = player_stats

			# change in health
			if player_stats["stats"]["health"] != Global.player["stats"]["health"]:

				# lose health
				if player_stats["stats"]["health"] < Global.player["stats"]["health"]:
					print("Player took %s damage." % str(character["stats"]["health"] - player_stats["stats"]["health"]))
				# gained health
				else:
					print("Player healed %s health." % str(abs(character["stats"]["health"] - player_stats["stats"]["health"])))
				Global.player["stats"]["health"] = player_stats["stats"]["health"]
				Signals.emit_signal("update_health")
				
			# level check -> exp check
			if player_stats["stats"]["level"] > Global.player["stats"]["level"]:
				print("Level up")
				Global.player["stats"]["experience"] = player_stats["stats"]["experience"]
				Global.player["stats"]["level"] = player_stats["stats"]["level"]
				Signals.emit_signal("update_level")
				Signals.emit_signal("update_exp")

			elif player_stats["stats"]["experience"] > Global.player["stats"]["experience"]:
					print("Player gained %s exp." % str(player_stats["stats"]["experience"] - Global.player["stats"]["experience"]))
					Global.player["stats"]["experience"] = player_stats["stats"]["experience"]
					Signals.emit_signal("update_exp")
			break

func portal(portal):
	rpc_id(1, "portal", portal)
	print("RPC to server for portal")

# warning-ignore:unused_argument
remote func return_portal(player_id):
	print("got return from server portal")
#
remote func change_map(map, position):
	Global.last_portal = position
	SceneHandler.change_scene(str(map)) 

# takes dictionary { 'T': client tick world state, 'P': server.position}
remote func return_player_input(server_input_results):
	Global.server_reconciliation(server_input_results)

remote func receive_climb_data(climb_data):
	var player = get_node("/root/currentScene/Player")
	if climb_data == 2:
		print("server: is climbing")
		player.can_climb = true
		player.is_climbing = true
	elif climb_data == 1:
		print("server: can climb")
		player.is_climbing = false
		player.can_climb = true
	else:
		player.can_climb = false
		player.is_climbing = false

func logout():
	timer.stop()
	network.close_connection()
	SceneHandler.change_scene("login")
