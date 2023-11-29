extends Node

var network = ENetMultiplayerPeer.new()
var port = 2734
var cert = load("res://resources/Certificate/X509_Certificate.crt")
var gateway_api = null
var username
var password

func _ready():
	"""
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
"""

func _process(_delta):
	if gateway_api == null:
		return
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()

func connect_to_server(_username, _password):
	username = _username
	password = _password
	await get_tree().create_timer(1).timeout
	network.create_client(Global.ip, port)
	
	gateway_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	gateway_api.connected_to_server.connect(_Connection_Succeeded)
	gateway_api.connection_failed.connect(_Connection_Failed)

func _Connection_Failed():
	print("Failed to conect to login server")
	print("Pop-up server offline")
	Signals.emit_signal("fail_login")
	
	network.close_connection()
	get_tree().set_multiplayer(null)
	get_tree().set_multiplayer(null)

func _Connection_Succeeded():
	print("Successfully connected to gateway")
	print("Custom Peers: {0}".format([multiplayer.get_peers()]))
	request_login()

func request_login():
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password)
	username = ""
	password = ""

@rpc("any_peer")
func login_request(_username, _password):
	pass

@rpc('any_peer')
func return_login(result):
	"""
	results[0] = code
	results[1] = {token, id}
	"""
	print(result)
	rpc_id(1, "client_disconnect")
	print("sending gateway disconnect")
	if result[0] == 200:
	
		Server.token = result[1]
		Server.connect_to_server()
	else:
		print("Please provide correct username and pasword")
	gateway_api.connected_to_server.disconnect(_Connection_Succeeded)
	gateway_api.connection_failed.disconnect(_Connection_Failed)

@rpc("any_peer")
func client_disconnect():
	pass



