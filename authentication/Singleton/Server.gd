extends Node

var network = ENetMultiplayerPeer.new()
var hub_api : MultiplayerAPI
var port = 2736
var max_players = 100
var server_list = {}

func _ready():
	start_server()

func _process(_delta):
	if not hub_api.has_multiplayer_peer():
		return
	hub_api.poll()
	
func start_server():
	network.create_server(port, max_players)
	hub_api =  MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(hub_api, self.get_path())
	hub_api.multiplayer_peer = network
	hub_api.peer_connected.connect(_Peer_Connected)
	hub_api.peer_disconnected.connect(_Peer_Disconnected)
	print("GameServerHub started")

	network.connect("peer_connected", Callable(self, "_Peer_Connected"))
	network.connect("peer_disconnected", Callable(self, "_Peer_Disconnected"))

func _Peer_Connected(server_id):
	print("server " + str(server_id) + " Connected")
	server_list["GameServer1"] = server_id
	
func _Peer_Disconnected(gameserver_id):
	print("server " + str(gameserver_id) + " Disconnected")
	
func distribute_login_token(token, server):
	var server_peer_id = server_list[server]
	print("sent token to server")
	rpc_id(server_peer_id, "received_login_token", token)
	
	
