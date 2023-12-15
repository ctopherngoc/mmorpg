extends Node2D

onready var verify_button = $Create/Verify
onready var create_button = $Create/Create
onready var username_field = $Create/usernameField
onready var dictionary = "ABCDEFGHIJKLMOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
onready var character_count
var display_name
var new_username
var username_check

onready var dudu = null
func _ready():
	pass

func _on_Create_pressed():
	create_button.disabled = true
	if username_check and username_field.text == new_username:
		if string_validation(new_username):
			var char_dict = $ColorRect/PlayerCreate.compile_char_data()
			char_dict["un"] = new_username
			Server.create_character(get_instance_id(), char_dict)
	else:
		$Create/notification/Label.text = "check username availability"
		create_button.disabled = false
		
func username_check_results(results):
	if results:
		username_check = true
		$Create/notification/Label.text = "username not taken"
	else:
		$Create/notification/Label.text = "username taken"
	
func _on_Verify_pressed():
	verify_button.disabled = true
	var username = username_field.text.strip_edges().strip_escapes()
	print ("checking username: %s" % username)
	
	if string_validation(username):
		Server.check_usernames(get_instance_id(), username)
		verify_button.disabled = false
		new_username = username
	
func created_character():
	print("successfully created character")
	SceneHandler.change_scene("characterSelect")

func string_validation(username):
	if username.length() < 6:
		$Create/notification/Label.text = "username must be at least 6 characters"
		verify_button.disabled = false
		return false
	for letter in username:
		if not letter in dictionary:
			$Create/notification/Label.text = "invalid username"
			verify_button.disabled = false
			return false
	for banned_word in GameData.string_validation:
		if banned_word in username.to_lower():
			$Create/notification/Label.text = "contains inappropirate words"
			verify_button.disabled = false
			return false
	return true



func _on_Button_pressed():
	SceneHandler.change_scene("characterSelect")
