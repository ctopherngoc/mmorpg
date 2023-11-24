extends Control

#onready var http : HTTPRequest = $HTTPRequest
@onready var username : LineEdit = $VBoxContainer/username/LineEdit
@onready var password : LineEdit = $VBoxContainer/password/LineEdit
@onready var notification : Label = $VBoxContainer/notification/Label
@onready var login_button : Button = $VBoxContainer/loginButton/Button

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Signals.connect("fail_login", Callable(self, "_fail_login"))

func _on_Button_pressed() -> void:
	if username.text.is_empty() or password.text.is_empty():
		notification.text = "Enter username and password"
	else:
		login_button.disabled = true
		Server.email = username.text
		Gateway.connect_to_server(username.text, password.text)

func _fail_login() -> void:
	login_button.disabled = false
	print("login failed. Login button clickable")

