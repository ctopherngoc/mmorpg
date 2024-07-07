######################################################################
# Singleton that establishes connection with game server
# Communicates client with current Server information
######################################################################

extends Node
var port = 2733
var token
var email
var network = null
var testing = false

var login_status = 0

var latency_array = []
var latency = 0 
var delta_latency = 0
var client_clock = 0
var decimal_collector = 0
var server_status = false
var timer = Timer.new()

func _ready() -> void:
	timer.wait_time = 0.5
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)

func _physics_process(delta: float) -> void:
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	#print(latency_array)
######################################################################
# Server connection/latency functions
func connect_to_server() -> void:
	network = NetworkedMultiplayerENet.new()
	network.create_client(Global.ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_on_server_disconnect")
# warning-ignore:return_value_discarded
	Signals.connect("drop_quantity", self, "drop_request")

func _on_connection_failed() -> void:
	print("Failed to connected")

func _on_connection_succeeded() -> void:
	server_status = true
	print("Successfully connected")
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	timer.start()

func _on_server_disconnect() -> void:
	server_status = false
	Global.world_state_buffer.clear()
	Global.input_queue.clear()
	Signals.emit_signal("log_out")
	print("server disconnected")
	
	if login_status == 1:
		SceneHandler.change_scene("login")
		login_status = 0
	get_tree().set_network_peer(null)

######################################################################
# client ping calculations 

# ping calulation. Should be used when lag compensation is implemented 
# with server reconciliation
func determine_latency() -> void:
	#rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())

# sync client clock with server clock
remote func return_server_time(server_time: int, client_time:int) -> void:
# warning-ignore:integer_division
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

remote func return_latency(client_time: int) -> void:
# warning-ignore:integer_division
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
func check_usernames(requester, username: String) -> void:
	print("check_usernames: %s %s" % [typeof(requester), typeof(username)])
	print("check_username", typeof(requester), typeof((username)))
	rpc_id(1, "fetch_usernames", requester, username)

remote func return_fetch_usernames(requester, results) -> void:
	print("return_fetch_usernames: %s %s" % [typeof(requester), typeof(results)])
	print("server username check: %s" % str(results))
	instance_from_id(requester).username_check_results(results)

func create_character(requester, char_dict):
	print("attempting to create character: %s" % char_dict["un"])
	rpc_id(1, "create_character", requester, char_dict)

remote func return_create_characters(requester, character_array: Array) -> void:
	print("return_create_characters: %s %s" % [typeof(requester), typeof(character_array)])
	print('return_create_characters')
	Global.character_list = character_array
	instance_from_id(requester).created_character()

func delete_character(requester, username: String) -> void:
	print("delete_character: %s %s" % [typeof(requester), typeof(username)])
	print("attempting to delete character: %s" % username)
	rpc_id(1, "delete_character", requester, username)

remote func return_delete_character(player_array, requester) -> void:
	print("return_delete_character: %s %s" % [typeof(player_array), typeof(requester)])
	Global.character_list = player_array
	instance_from_id(requester).populate_info()
	instance_from_id(requester).deleted_character()
	print("deleted character")

func choose_character(requester: int, player_name: String):
	rpc_id(1, "choose_character", requester, player_name)

# warning-ignore:unused_argument
remote func return_choose_character(requester: int) -> void:
	SceneHandler.change_scene(Global.player['map']) 
	#instance_from_id(requester).load_world()

##############################################################################
# Authentication
remote func fetch_token() -> void:
	rpc_id(1, "return_token", token, email)

remote func return_token_verification_results(result: bool, array: Array) -> void:
	print("server.gd: return_token_verification_results")
	if result == true:
		print("token verified")
		Global.character_list = array
#		fetch_player_stats()
		login_status = 1
		SceneHandler.change_scene("characterSelect")
	else:
		print("token unverified")
		var login_scene = get_tree().get_current_scene()
		login_scene.login_button.disabled = false
		login_scene.notification.text = "login failed, please try again"

remote func already_logged_in() -> void:
	print("server.gd: already_logged_in")
	var login_scene = get_tree().get_current_scene()
	login_scene.login_button.disabled = false
	login_scene.notification.text = "Account already logged in"
	timer.stop()
	get_tree().set_network_peer(null)

#################################################################################
# Player functions
remote func despawn_player(player_id: int) -> void:
	print("server.gd: despawn player")
	var other_players = get_node("/root/GameWorld/MapNode/%s/OtherPlayers"% Global.current_map) 
	for player in other_players.get_children():
		print(str(player) + str(player_id))
		if player.name == str(player_id):
			print("matches despawning char")
			player.queue_free()

func send_player_state(player_state: Dictionary) -> void:
	if !testing:
		if Global.in_game:
			rpc_unreliable_id(1, "received_player_state", player_state)

remote func receive_world_state(world_state: PoolByteArray) -> void:
	if Global.current_map == "":
		pass
	else:
		var world_state_dict = bytes2var(world_state)
		Global.update_world_state(world_state_dict)

remote func receive_despawn_player(player_id) -> void:
	print("receive_despawn_player: %s" % typeof(player_id))
	Global.despawn_player(player_id)
	
func send_input(skill_id: int) -> void:
	#print("server.gd: send_attack")
	rpc_id(1, "receive_input", skill_id)

########################################################################################################
#not used
remote func receive_attack(player_id, attack_time):
	print("server.gd: recieve_attack")
	print(typeof(player_id), " ", typeof(attack_time))
	if player_id == get_tree().get_network_unique_id():
		print("self attack: pass")
	elif get_node("/root/GameWorld/MapNode/%s/OtherPlayers" % Global.current_map).has_node(str(player_id)):
		print(str(player_id) + " attack")
		var player = get_node("/root/GameWorld/MapNode/%s/OtherPlayers/%s" % [Global.current_map,player_id])
		player.attack_dict[attack_time] = {"A": "stab"}
	else:
		pass
########################################################################################################	

remote func update_player_stats(player_stats: Dictionary) -> void:
	for character in Global.character_list:
		if character["displayname"] == player_stats["displayname"]:
			character = player_stats
			Signals.emit_signal("update_stats")

			# change in health
			if player_stats["stats"]["base"]["health"] != Global.player["stats"]["base"]["health"]:

				# lose health
				if player_stats["stats"]["base"]["health"] < Global.player["stats"]["base"]["health"]:
					var damage_taken = Global.player["stats"]["base"]["health"] - player_stats["stats"]["base"]["health"]
					Signals.emit_signal("take_damage", damage_taken)
					print("Player took %s damage." % str(damage_taken))
				# gained health
				else:
					var heal_value = abs(Global.player["stats"]["base"]["health"] - player_stats["stats"]["base"]["health"])
					#print("Player healed %s health." % str(heal_value))
					Global.player_node.heal(heal_value)
				Global.player["stats"]["base"]["health"] = player_stats["stats"]["base"]["health"]
				Signals.emit_signal("update_health")
				
				# mana
				Global.player["stats"]["base"]["mana"] = player_stats["stats"]["base"]["mana"]
				
			# level check -> exp check
			if player_stats["stats"]["base"]["level"] != Global.player["stats"]["base"]["level"]:
				print("Level up")
				Global.player["stats"]["base"]["experience"] = player_stats["stats"]["base"]["experience"]
				Global.player["stats"]["base"]["level"] = player_stats["stats"]["base"]["level"]
				Global.player["stats"]["base"]["maxHealth"] = player_stats["stats"]["base"]["maxHealth"]
				Global.player["stats"]["base"]["maxMana"] = player_stats["stats"]["base"]["maxMana"]
				Signals.emit_signal("update_level")
				Signals.emit_signal("update_health")
				Signals.emit_signal("update_mana")
				Signals.emit_signal("level_up")
				Signals.emit_signal("update_exp")

			if player_stats["stats"]["base"]["experience"] != Global.player["stats"]["base"]["experience"]:
					print("Player gained %s exp." % str(player_stats["stats"]["base"]["experience"] - Global.player["stats"]["base"]["experience"]))
					Global.player["stats"]["base"]["experience"] = player_stats["stats"]["base"]["experience"]
					Signals.emit_signal("update_exp")
			
			if not dictionary_comparison(Global.player["inventory"], player_stats["inventory"]):
			#if player_stats["inventory"].hash() != Global.player["inventory"].hash():
				Global.player["inventory"] = player_stats["inventory"]
				Signals.emit_signal("update_inventory")
			
			#if not dictionary_comparison(Global.player["equipment"], player_stats["equipment"]):
			if player_stats["equipment"].hash() != Global.player["equipment"].hash():
				print("pls work")
				Global.player["equipment"] = player_stats["equipment"]
				Signals.emit_signal("update_equipment")
				Signals.emit_signal("update_sprite")
			
			if not dictionary_comparison(Global.player["skills"], player_stats["skills"]):
			#if player_stats["inventory"].hash() != Global.player["inventory"].hash():
				Global.player.stats = player_stats["stats"]
				Global.player["skills"] = player_stats["skills"]
				Signals.emit_signal("update_skills")
				
			if player_stats.stats.hash() != Global.player.stats.hash():
				Global.player.stats = player_stats.stats
			
			if not dictionary_comparison(Global.player["keybind"], player_stats["keybind"]):
			#if player_stats["inventory"].hash() != Global.player["inventory"].hash():
				print("update keybinds")
				Global.player["keybind"] = player_stats["keybind"]
				Signals.emit_signal("update_keybinds")
			break

func dictionary_comparison(client_dict: Dictionary, server_dict: Dictionary) -> bool:
	for key in client_dict:
		if not server_dict.has(key):
			return false
		var tv = client_dict[key]
		if typeof(tv) == TYPE_DICTIONARY:
			if !dictionary_comparison(tv, server_dict[key]):
				return false
		elif tv != server_dict[key]: 
			return false
	return true
	
func portal(portal: String) -> void:
	AudioControl.play_audio("portal")
	rpc_id(1, "portal", portal)
	#print("RPC to server for portal")

# warning-ignore:unused_argument
remote func return_portal(player_id: int) -> void:
	pass
	print("got return from server portal")
#
remote func change_map(map: String, position: Vector2) -> void:
	Global.last_portal = position
	SceneHandler.change_scene(str(map)) 

# takes dictionary { 'T': client tick world state, 'P': server.position}
remote func return_player_input(server_input_results):
	Global.server_reconciliation(server_input_results)

remote func receive_climb_data(climb_data: int) -> void:
	if Global.in_game:
		var player = get_node("/root/GameWorld/MapNode/%s/Player" % Global.current_map)
		if climb_data == 2:
			player.can_climb = true
			player.is_climbing = true
		elif climb_data == 1:
			player.is_climbing = false
			player.can_climb = true
		else:
			player.can_climb = false
			player.is_climbing = false

func logout() -> void:
	timer.stop()
	Global.in_game = false
	if !Server.testing:
		network.close_connection()
		rpc_id(1, "logout")
	Signals.emit_signal("log_out")
	SceneHandler.change_scene("login")
	
func send_inventory_movement(tab: int, from: int, to: int) -> void:
	"""
	tab: 0 = equip, 1 = use, 2 = etc
	from: 0-31 (slot)
	to: 0-31(slot)
	"""
	rpc_id(1, "move_item", [tab, from, to])

func send_equipment_request(equipment_slot, inventory_slot) -> void:
	print("send_equipment_request succcess")
	rpc_id(1, "equipment_request", equipment_slot, inventory_slot)

#remote func return_equipment_request() -> void:
#	pass
	
func remove_equipment_request(equipment_slot, inventory_slot) -> void:
	print("remove_equipment_request succcess")
	print(equipment_slot, " ", inventory_slot)
	rpc_id(1, "remove_equipment_request", equipment_slot, inventory_slot)

#remote func return_remove_equipment_() -> void:
#	pass
	
remote func server_message(message: String):
	print("received messge %s" % message)
	
remote func loot_data(_item_data: Dictionary) -> void:
	AudioControl.play_audio("loot")
	# update notification
	# var string
	# if item_data.id = 10000:
		# string = "Picked up %s gold" % GameData[item_data.q]"
	# else:
		# var string = "Picked up %s" % GameData[item_data.id]"
	#update_message(string)

remote func update_messages(player_name: String, message: String ,group: int) -> void:
	print("%s said %s in %s" % [player_name, message, group])
	Global.ui.ui_nodes.chat_box.update_message(player_name, message, group) 
	# insert script to edit notification var with message

func use_item(item_id: String, slot_index: int) -> void:
	print("in use_item -> server rpc")
	rpc_id(1, "use_item", [item_id, slot_index])
	
func add_stat(stat: String) -> void:
	print("requesting to add %s" % stat)
	rpc_id(1, "add_stat", stat)

func send_chat(text: String, chat_type: int) -> void:
	rpc_id(1, "send_chat", text, chat_type)

func drop_request(slot: int, tab: String, quantity: int = 1) -> void:
	rpc_id(1, "drop_request", slot, tab, quantity)
	
func update_keybind(key: String, type: String, id: String) -> void:
	print("%s: %s" % [type,id])
	rpc_id(1, "update_keybind", key, type, id)

func swap_keybind(key1, key2) -> void:
	rpc_id(1, "swap_keybind", key1, key2)

func remove_keybind(key) -> void:
	rpc_id(1, "remove_keybind", key)
	
func use_skill(id: String) -> void:
	Signals.emit_signal("use_skill", GameData.animation_dict[id])
	print("attempt to use skill %s" % id)
	rpc_id(1, "skill_request", id)
	
func increase_skill(id: String, level: int) -> void:
	rpc_id(1, "increase_skill", id, level)
