extends Control

const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
var current_token = ""
onready var http: HTTPRequest = $HTTPRequest

onready var email: LineEdit = $VBoxContainer/username/LineEdit
onready var password: LineEdit = $VBoxContainer/password/LineEdit
onready var confirm: LineEdit = $VBoxContainer/password2/LineEdit
onready var notification: Label = $VBoxContainer/notification/Label
onready var createButton: Button = $VBoxContainer/registerButton/Button

func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	createButton.disabled = true;
	if password.text != confirm.text:
		notification.text = "passwords do not match"
		return
	elif password.text.empty() or email.text.empty() or confirm.text.empty():
		notification.text = "empty fields"
		return
	else:
		register(email.text, password.text, http)

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

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		createButton.disabled = false;
		notification.text = response_body.result.error.messsage.capitalize()
	else:
		notification.text = "Registration Successful! Returning to Login Screen in 2 Seconds"
		yield(get_tree().create_timer(2.0), "timeout")
		SceneHandler.change_scene("login")
		# insert scene change manager command to go back to login screen


func _on_backButton_pressed():
	SceneHandler.change_scene("login")
