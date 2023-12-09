extends Control

#onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $VBoxContainer/username/LineEdit
onready var password : LineEdit = $VBoxContainer/password/LineEdit
onready var notification : Label = $VBoxContainer/notification/Label
onready var login_button : Button = $VBoxContainer/loginButton/Button

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Signals.connect("fail_login", self, "_fail_login")

func _on_Button_pressed() -> void:
	if username.text.empty() or password.text.empty():
		notification.text = "Enter username and password"
	else:
		login_button.disabled = true
		Server.email = username.text
		Gateway.connect_to_server(username.text, password.text)

func _fail_login() -> void:
	login_button.disabled = false
	print("login failed. Login button clickable")



func _on_Button1_pressed():
	Global.player = GameData.test_player
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/maps/100000/100000.tscn")
	#SceneHandler.change_scene("res://scenes/maps/100001/100001.tscn")
