extends Node
var network
var ip = "127.0.0.1"
var port = 1000
var token
var email

var loginStatus = 0

var latency_array = []
var latency = 0 
var delta_latency = 0
var client_clock = 0
var decimal_collector = 0
var serverStatus = false
var timer = Timer.new()

func _ready():
	timer.wait_time = 0.5
	#timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
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
func ConnectToServer():
	var network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	network.connect("server_disconnected", self, "_OnServerDisconnect")

func _OnConnectionFailed():
	print("Failed to connected")


func _OnConnectionSucceeded():
	serverStatus = true
	print("Successfully connected")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	#var timer = Timer.new()
	#timer.wait_time = 0.5
	#timer.autostart = true
	#timer.connect("timeout", self, "DetermineLatency")
	#self.add_child(timer)
	timer.start()

func _OnServerDisconnect():
	serverStatus = false
	Global.world_state_buffer.clear()
	timer.stop()
	print("server disconnected")
	
	if loginStatus == 1:
		SceneHandler.changeScene(SceneHandler.scenes["mainMenu"])
		loginStatus = 0
		#self.get_node("timer").queue_free()
#	SceneHandler.changeMenuMessage("Server Disconnected")

func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())

remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

remote func ReturnLatency(client_time):
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
		#print("New Latency ", latency)
		# print("Delta Latency ", delta_latency)
		latency_array.clear()

#################################################################
# Character functions
func FetchCharacters():
	rpc_id(1, "FetchCharacters")

remote func ReturnFetchCharacter(results):
	pass
	print(results)

func checkUsernames(requester, username):
	rpc_id(1, "fetchUsernames", requester, username)

remote func returnfetchUsernames(requester, results):
	print("client results from fetchUsernames: %s" % str(results))
	instance_from_id(requester).returnUsernameCheck(results)

func createCharacter(requester, username):
	print("attempting to create character: %s" % username)
	rpc_id(1, "createCharacter", requester, username)

remote func returnCreateCharacters(requester, characterArray: Array):
	print('returnCreateCharacters')
	Global.character_list = characterArray
	instance_from_id(requester).successfulCreatedChar()

func deleteCharacter(requester, username):
	print("attempting to delete character: %s" % username)
	rpc_id(1, "deleteCharacter", requester, username)

remote func returnDeleteCharacter(playerArray, requester):
	Global.character_list = playerArray
	instance_from_id(requester).populateCharacterInfo()
	instance_from_id(requester).successfulDeleteChar()
	print("deleted character")

func ChooseCharacter(requester, charactername):
	rpc_id(1, "ChooseCharacter", requester, charactername)

remote func ReturnChooseCharacter(requester):
	#print("returnchoosecharacter")
	instance_from_id(requester).EnterMap()

# not sure if server use this
# warning-ignore:unused_argument
remote func updateAccountData(requester, characterArray: Array):
	Global.character_list = characterArray

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	get_node("/root/currentScene/Player/Camera2D/UI/PlayerStats").LoadPlayerStats(stats)

#########################################################################
# Player/monster damage calculations to server
# not in use
func fetchPlayerDamage(requester):
	rpc_id(1, "fetchPlayerDamage", requester)
	
func fetchMonsterDamage(requester):
	rpc_id(1, "fetchMonsterDamage", requester)
	
remote func returnPlayerDamage(s_damage, requester):
	print("retunplayerdamage damage = %s" % s_damage)
	instance_from_id(requester).setDamage(s_damage)
	
remote func returnMonsterDamage(s_damage, requester):
	print("retunmonserdamage damage = %s" % s_damage)
	instance_from_id(requester).setDamage(s_damage)


##############################################################################
# Authentication
remote func FetchToken():
	rpc_id(1, "ReturnToken", token, email)

remote func ReturnTokenVerificationResults(result, array):
	if result == true:
		print("Successful token verification")
		# print(array)
		Global.character_list = array
		FetchPlayerStats()
		loginStatus = 1
		SceneHandler.changeScene(SceneHandler.scenes["characterSelect"])
	else:
		print("login failed, please try again")
		var loginScene = get_tree().get_current_scene()
		loginScene.login_button.disabled = false
		loginScene.notification.text = "login failed, please try again"

remote func AlreadyLoggedIn():
	print("Account already logged in")
	var loginScene = get_tree().get_current_scene()
	loginScene.login_button.disabled = false
	loginScene.notification.text = "Account already logged in"
	#timer.queue_free()
	timer.stop()
	#network.disconnect("connection_failed", self, "_OnConnectionFailed")
	#network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	#network.disconnect("server_disconnected", self, "_OnServerDisconnect")
	#network.close_connection()

#################################################################################
# Player functions
remote func SpawnNewPlayer(player_id, map):
	Global.SpawnNewPlayer(player_id, map)
		
	#get_node("../SceneHandler/currentScene").SpawnNewPlayer(player_id)

remote func DespawnPlayer(player_id):
	print("inside despawn player")
	var otherPlayers = get_node("/root/currentScene/OtherPlayers")
	for player in otherPlayers.get_children():
		print(str(player) + str(player_id))
		if player.name == str(player_id):
			print("mnatches despawning char")
			player.queue_free()
	#get_node("../SceneHandler/currentScene").DespawnPlayer(player_id)

func SendPlayerState(player_state):
	#print(player_state)
	rpc_unreliable_id(1, "ReceivedPlayerState", player_state)

remote func ReceiveWorldState(world_state):
	if Global.current_map == "":
		pass
	else:	
		# print(world_state)
		Global.UpdateWorldState(world_state)
		#print("Worldstate: ", world_state["T"], " && client_clock: ", client_clock)

remote func ReceiveDespawnPlayer(player_id):
	Global.DespawnPlayer(player_id)
	
func SendAttack():
	print("sending my attack")
	rpc_id(1, "Attack", Server.client_clock)
	
remote func ReceiveAttack(player_id, attack_time):
	print("attack recieved")
	if player_id == get_tree().get_network_unique_id():
		print("this is my own attack. pass")
		pass
	elif get_node("/root/currentScene/OtherPlayers").has_node(str(player_id)):
		print(str(player_id) + " attack")
		var player = get_node("/root/currentScene/OtherPlayers/%s" % player_id)
		player.attack_dict[attack_time] = {"A": "stab"}
	else:
		pass

remote func UpdatePlayerStats(player_stats):
	print(player_stats)
	Global.player = player_stats
	for character in Global.character_list:
		if character["displayname"] == player_stats["displayname"]:
			var playerNode = get_node("/root/currentScene/Player")
			# hp check
			if player_stats["stats"]["health"] < character["stats"]["health"]:
					playerNode.health = player_stats["stats"]["health"]
					print("Player took %s damage." % str(character["stats"]["health"] - player_stats["stats"]["health"]))
			
			# level check -> exp check
			if player_stats["stats"]["level"] > character["stats"]["level"]:
				print("Level up")
				playerNode.player["stats"]["experience"] = player_stats["stats"]["experience"]
				playerNode.player["stats"]["level"] = player_stats["stats"]["level"]
				# Add sp points, ability points
				
			elif player_stats["stats"]["experience"] > character["stats"]["experience"]:
					playerNode.player["stats"]["experience"] = player_stats["stats"]["experience"]
					print("Player gained %s exp." % str(player_stats["stats"]["experience"] - character["stats"]["experience"]))
			character = player_stats
			playerNode.player = player_stats
			break

func Portal(portal):
	rpc_id(1, "Portal", portal)
	print("RPC to server for portal")
	
# warning-ignore:unused_argument
remote func ReturnPortal(player_id):
	print("got return from server portal")
#
remote func changeMap(map, position):
	Global.last_portal = position
	SceneHandler.changeScene("res://scenes/maps/%s.tscn" % map) 
