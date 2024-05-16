extends Control

#onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $VBoxContainer/username/LineEdit
onready var password : LineEdit = $VBoxContainer/password/LineEdit
onready var notification : Label = $VBoxContainer/notification/Label
onready var login_button : Button = $VBoxContainer/loginButton/Button
onready var register_button: Button = $VBoxContainer/loginButton/RegisterButton
onready var MainMenu = $VBoxContainer
onready var OptionMenu = $Options
onready var savelogin = false
onready var login_file_path = "login.bat"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Signals.connect("fail_login", self, "_fail_login")
	load_settings()

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

func _on_Button2_pressed() -> void:
	AudioControl.play_audio("menuClick")
	MainMenu.hide()
	OptionMenu.show()

func _on_back_pressed() -> void:
	#SoundManager.PlayButtonPressDown()
	MainMenu.show()
	#Title.show()
	OptionMenu.hide()

func _on_RegisterButton_pressed() -> void:
	AudioControl.play_audio("menuClick")
	SceneHandler.change_scene("register")

func _on_Button_mouse_entered() -> void:
	AudioControl.play_audio("menuHover")
	
func return_to_login() -> void:
	OptionMenu.hide()
	MainMenu.show()

func _on_LineEdit_text_entered(_new_text: String) -> void:
	login_request()

func _on_LineEdit_text_changed(_new_text: String) -> void:
	AudioControl.play_audio("typing")

func _on_LineEdit_mouse_entered() -> void:
	AudioControl.play_audio("menuHover")

func _on_LineEdit_focus_entered() -> void:
	AudioControl.play_audio("menuClick")

func _on_CheckBox_toggled(button_pressed):
	if $VBoxContainer/loginButton/Label.pressed:
		savelogin = true
	else:
		savelogin = false

func _on_LineEdit_focus_exited():
	save_settings(savelogin)

func save_settings(save: bool) -> void:
	var email = $VBoxContainer/username/LineEdit.text
	var file = File.new()
	file.open(login_file_path, file.WRITE)
	var data
	if save:
		data ={ "login" : {"email": email,
					"save": true}}
	else:
		data ={ "login" : {"save": true}}	
	file.store_line(JSON.print(data, "\t"))
	file.close()
	
func load_settings() -> void:
	var save_file = File.new()
	if not save_file.file_exists(login_file_path):
		return
	save_file.open(login_file_path, File.READ)
	var settings_data = JSON.parse(save_file.get_as_text())
	var login_settings = settings_data.result["login"]
	if login_settings.save:
		$VBoxContainer/username/LineEdit.text = settings_data.email
	print("Loaded")
	save_file.close()

