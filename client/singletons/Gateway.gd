extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 2734
var cert = load("res://resources/Certificate/X509_Certificate.crt")

var username
var password

func _ready():
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server(_username, _password):
	username = _username
	password = _password
	network.create_client(Global.ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)

func _on_connection_failed():
	print("Failed to conect to login server")
	print("Pop-up server offline")
	Server.email = null
	Signals.emit_signal("fail_login")
	network.close_connection()
	#custom_multiplayer.set_network_peer(null)


func _on_connection_succeeded():
	print("Successfully connected to login server")
	request_login()

remote func request_login():
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""

remote func return_login_request(results):
	"""
	results[0] = code
	results[1] = {token, id}
	"""
	if results[0] == 200:
	
		Server.token = results[1]
		# pass email to below
		Server.connect_to_server()
	else:
		print("Please provide correct username and pasword")
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded") 
