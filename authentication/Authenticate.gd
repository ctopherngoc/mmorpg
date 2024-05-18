extends Node

# singleton: http.gd links variable to httprequest
onready var http
var network = NetworkedMultiplayerENet.new()
var port = 2735
var max_servers = 5
func _ready():
	start_server()

func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication server started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Discnnected")

func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")

func _Peer_Disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")
	
remote func authenticate_player(username, password, player_id):
	print("authentication request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	
	print("Starting authentication")
	#print("this is http: %s" % http)
	var results = []
	var firebaseStatus = Firebase.login(username, password, http, results)
	yield(firebaseStatus, "completed")
	#print(results)
	if results[0] != 200:
		print("Signin Unsuccessful")
	else:
		print("Signin Successful")
		var server = "GameServer1"
		if not Firebase.account_id_list.has(str(results[1].id)):
			Firebase.account_id_list.append(str(results[1].id))
			var url = "users/%s" % str(results[1].id)
			Firebase.update_document(url)
		var temp_token = results[1]['token'] + str(results[1]['timestamp'])
		Server.distribute_login_token(temp_token, server)
		
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "authentication_results", results, player_id)
