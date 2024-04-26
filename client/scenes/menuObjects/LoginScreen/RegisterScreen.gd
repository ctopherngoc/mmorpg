extends Control

const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
var current_token = ""
onready var http = $HTTPRequest

onready var email: LineEdit = $VBoxContainer/username/LineEdit
onready var password: LineEdit = $VBoxContainer/password/LineEdit
onready var email: LineEdit = $VBoxContainer/username/LineEdit

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	pass # Replace with function body.

func _get_token_id_from_result(result: Array) -> String:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return result_body.idToken
	
func register(email: String, password: String, http) -> void:
	var body := {
		"email": email,
		"password": password,
	}
	
	http.request(REGISTER_URL, [], false, http.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		current_token = _get_token_id_from_result(result)
