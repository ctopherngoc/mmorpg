extends Control

#onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $VBoxContainer/username/LineEdit
onready var password : LineEdit = $VBoxContainer/password/LineEdit
onready var notification : Label = $VBoxContainer/notification/Label
onready var login_button : Button = $VBoxContainer/loginButton/Button
onready var register_button: Button = $VBoxContainer/loginButton/RegisterButton
onready var MainMenu = $VBoxContainer
onready var OptionMenu = $Options

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Signals.connect("fail_login", self, "_fail_login")

func _on_Button_pressed() -> void:
	AudioControl.play_audio("menuClick")
	login_request()

func login_request() -> void:
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
	AudioControl.play_audio("menuClick")
	Global.player = GameData.test_player
	Server.testing = true
	# warning-ignore:return_value_discarded
	SceneHandler.change_scene("100000")

func _on_Button2_pressed():
	AudioControl.play_audio("menuClick")
	MainMenu.hide()
	OptionMenu.show()

func _on_back_pressed():
	#SoundManager.PlayButtonPressDown()
	MainMenu.show()
	#Title.show()
	OptionMenu.hide()

func _on_RegisterButton_pressed():
	AudioControl.play_audio("menuClick")
	SceneHandler.change_scene("register")

func _on_Button_mouse_entered():
	AudioControl.play_audio("menuHover")
	
func return_to_login() -> void:
	OptionMenu.hide()
	MainMenu.show()


func _on_LineEdit_text_entered(new_text):
	login_request()


func _on_LineEdit_text_changed(new_text):
	AudioControl.play_audio("typing")


func _on_LineEdit_mouse_entered():
	AudioControl.play_audio("menuHover")


func _on_LineEdit_focus_entered():
	AudioControl.play_audio("menuClick")
