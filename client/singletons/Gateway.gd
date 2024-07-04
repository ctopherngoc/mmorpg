######################################################################
# Client-Gateway Singleton interface. Netcode to connect client to gateway server to login
######################################################################
extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 2734
var cert = load("res://resources/Certificate/X509_Certificate.crt")
var login_node

var username
var password

func _ready():
	pass

func _process(_delta: float) -> void:
	
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server(_username: String, _password: String) -> void:
	print("connecting to gateway")
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	
	username = _username
	password = _password
	network.create_client(Global.ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	# start timer to time out login

func _on_connection_failed() -> void:
	print("Failed to conect to login server")
	print("Pop-up server offline")
	Server.email = null
	Signals.emit_signal("fail_login")

func _on_connection_succeeded() -> void:
	print("Successfully connected to login server")
	request_login()

func request_login() -> void:
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password, Global.version)
	username = ""
	password = ""

remote func return_login_request(results: Array) -> void:
	"""
	results[0] = code
	results[1] = {token, id}
	"""
	if results[0] == 200:
	
		Server.token = results[1]
		# pass email to below
		Server.connect_to_server()
	elif results[0] == 2733:
		print("wrong version. please update game client to version %s", results[1])
		login_node.notification.modulate = Color(1.0,0.0,0.0,1.0)
		login_node.notification.text = ("incorrect version.\n\nplease update client to version %s" % results[1])
		Signals.emit_signal("fail_login")
	else:
		print("Please provide correct username and pasword")
		Signals.emit_signal("fail_login")

# timer_signal:
# Signals.emit_signal("failed_login")
# network.close_connection()
