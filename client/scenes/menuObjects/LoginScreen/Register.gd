extends Control

onready var http: HTTPRequest = $HTTPRequest
onready var email: LineEdit = $VBoxContainer/username/LineEdit
onready var password: LineEdit = $VBoxContainer/password/LineEdit
onready var confirm: LineEdit = $VBoxContainer/password2/LineEdit
onready var notification: Label = $VBoxContainer/notification/Label
onready var createButton: Button = $VBoxContainer/registerButton/Button

func _ready():
	notification.add_color_override("font_color", Color("ff0300"))

func _on_Button_pressed():
	createButton.disabled = true;
	if password.text != confirm.text:
		notification.text = "passwords do not match"
		createButton.disabled = false;
		return
	elif password.text.empty() or email.text.empty() or confirm.text.empty():
		notification.text = "contains empty fields"
		createButton.disabled = false;
		return
	else:
		Firebase.register(email.text, password.text, http)

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print("request complete")
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		createButton.disabled = false;
		notification.text = response_body.result.error.message.capitalize()
	else:
		notification.text = "Registration Successful! Returning to Login Screen in 2 Seconds"
		yield(get_tree().create_timer(2.0), "timeout")
		SceneHandler.change_scene("login")
		# insert scene change manager command to go back to login screen


func _on_backButton_pressed():
	SceneHandler.change_scene("login")
