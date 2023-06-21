extends Node

# singleton: http.gd links variable to httprequest
onready var http : HTTPRequest
var network = NetworkedMultiplayerENet.new()
var port = 1943
var max_servers = 5

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Discnnected")
	
func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")

func _Peer_Disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")
	
remote func AuthenticatePlayer(username, password, player_id):
	print("authentication request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	
	########################
	#var result
	########################
	
	print("Starting authentication")
	print("this is http: %s" % http)
	var results = []
	var firebaseStatus = Firebase.login(username, password, http, results)
	yield(firebaseStatus, "completed")
	# print("this is results: %s " % str(results))
	
	if results[0] != 200:
		print("Signin Unsuccessful")
	else:
		print("Signin Successful")
		var gameserver = "GameServer1"
		var temp_token = results[1]['token'] + str(results[1]['timestamp'])
		#Server.DistributeLoginToken(results[1]['token'], gameserver)
		Server.DistributeLoginToken(temp_token, gameserver)
		
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", results, player_id)
	
####################################################
#	if not PlayerData.PlayerIDs.has(username):
#		result = false
#	elif not PlayerData.PlayerIDs[username].Password == password:
#		print("incorrect password")
#		result = false
######################################################
	
#func _on_HTTPRequest_request_completed(result, response_code, headers, body):
#	var results
#	var response_body := JSON.parse(body.get_string_from_ascii())
#	if response_code != 200:
#		print(response_body.result.error.message.capitalize())
#	else:
#		print("Signin Successful")
#	print("authentication result send to gateway server")
#	rpc_id(gateway_id, "AuthenticationResults", result, player_id)
	
