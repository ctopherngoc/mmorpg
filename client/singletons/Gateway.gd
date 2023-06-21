extends Node


var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1944
var ip = "127.0.0.1"
var cert = load("res://resources/Certificate/X509_Certificate.crt")

var username
var password

func _ready():
	pass

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func ConnectToServer(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to conect to login server")
	print("Pop-up server offline")
	# get_node("../scenes/userInterface/LoginScreen").login_button.disabled = false

func _OnConnectionSucceeded():
	print("Successfully connected to login server")
	RequestLogin()

remote func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""

remote func ReturnLoginRequest(results):
	#print("results received")
	#print(results)
	"""
	results[0] = code
	results[1] = {token, id}
	"""
	if results[0] == 200:
	
		Server.token = results[1]
		Server.ConnectToServer()
	else:
		print("Please provide correct username and pasword")
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

