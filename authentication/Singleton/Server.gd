extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1960
var max_players = 100

var gameServerList = {}

func _ready():
	StartServer()

# warning-ignore:unused_argument
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll()
	
func StartServer():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gameserver_id):
	print("server " + str(gameserver_id) + " Connected")
	gameServerList["GameServer1"] = gameserver_id
	
func _Peer_Disconnected(gameserver_id):
	print("server " + str(gameserver_id) + " Disconnected")
	
func DistributeLoginToken(token, gameserver):
	var gameServer_peer_id = gameServerList[gameserver]
	print("sent token to server")
	rpc_id(gameServer_peer_id, "ReceivedLoginToken", token)
	
	
