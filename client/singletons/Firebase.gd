extends Node

onready var REGISTER_URL: String
var current_token: String = ""

func _ready() -> void:
	var data_file = File.new()
	data_file.open("res://data/server.json", File.READ)
	var server_json = JSON.parse(data_file.get_as_text())
	REGISTER_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % server_json.result["API_KEY"]
	if Global.local:
		Global.ip = server_json.result["LOCAL_IP"]
	else:
		Global.ip = server_json.result["SERVER_IP"]
	data_file.close()

func _get_token_id_from_result(result: Array) -> String:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return result_body.idToken

func register(email: String, password: String, http) -> void:
	var body := {
		"email": email,
		"password": password,
	}
	
	http.request(REGISTER_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		current_token = _get_token_id_from_result(result)
		
