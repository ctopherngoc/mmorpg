extends Control

onready var level : LineEdit = $CharacterBox/Character1/Container/Level/LineEdit
onready var notification : Label = $SceneTitle/notification/Label
var new_profile := false
var information_sent := false

onready var check_button = $Create/UsernameCheck
onready var create_button = $Create/Create
onready var username_field = $Create/usernameField
onready var dictionary = "ABCDEFGHIJKLMOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
onready var character_count
var display_name
var new_username
var username_check
	
func _ready():
	populate_info()

func _process(_delta):
	pass
	
func populate_info():
	create_button.disabled = false
	if Global.character_list.empty():
		notification.text = "No Character Found"
	else:
		var size = Global.character_list.size()
		character_count = size
		if size >= 1:
			$CharacterBox/Character1.visible = true
			$CharacterBox/Character1/Container/CharacterName/LineEdit.text = str(Global.character_list[0]["displayname"])
			$CharacterBox/Character1/Container/Level/LineEdit.text = str(Global.character_list[0]["stats"]["level"])
			$CharacterBox/Character1.character_info = Global.character_list[0]

		if size >= 2:
			$CharacterBox/Character2.visible = true
			$CharacterBox/Character2/Container/CharacterName/LineEdit.text = str(Global.character_list[1]["displayname"])
			$CharacterBox/Character2/Container/Level/LineEdit.text = str(Global.character_list[1]["stats"]["level"])
			$CharacterBox/Character2.character_info = Global.character_list[1]

		if size == 3:
			create_button.disabled = true
			$CharacterBox/Character3.visible = true
			$CharacterBox/Character3/Container/CharacterName/LineEdit.text = str(Global.character_list[2]["displayname"])
			$CharacterBox/Character3/Container/Level/LineEdit.text = str(Global.character_list[2]["stats"]["level"])
			$CharacterBox/Character3.character_info = Global.character_list[2]

		notification.text = "Profile Loaded"

func widget_reset():
	$CharacterBox/Character1.visible = false
	$CharacterBox/Character2.visible = false
	$CharacterBox/Character3.visible = false
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = false
	$CharacterBox/Character3/ColorRect.visible = false

func _on_button1_pressed():
	$CharacterBox/Character1/ColorRect.visible = true
	Global.player = Global.character_list[0]
	if character_count == 2:
		$CharacterBox/Character2/ColorRect.visible = false
	if character_count == 3:
		$CharacterBox/Character2/ColorRect.visible = false

func _on_button2_pressed():
	Global.player = Global.character_list[1]
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = true
	if character_count == 3:
		$CharacterBox/Character3/ColorRect.visible = false

func _on_button3_pressed():
	Global.player = Global.character_list[2]
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = false
	$CharacterBox/Character3/ColorRect.visible = true

func _on_select_pressed():
	$Select.disabled = true
	if Global.player:
		Server.choose_character(get_instance_id(), Global.player['displayname'])
	else:
		$Select.disabled = false
		
func load_world():
	SceneHandler.change_scene(Global.player['map']) 

func _on_delete_pressed():
	print('Attempting to delete selected character')
	$Delete.disabled = true
	Server.delete_character(get_instance_id(), Global.player['displayname'])
"""
func _on_create_pressed():
	create_button.disabled = true
	if Global.character_list.size() == 3:
		$Create/notification/Label.text = "you already have maximum amount of characters"
		create_button.disabled = false
	elif username_check and username_field.text == new_username:
		if string_validation(new_username):
			Server.create_character(get_instance_id(), new_username)
	else:
		$Create/notification/Label.text = "check username availability"
		create_button.disabled = false

func create_profile(results):
	if results:
		populate_info()
		new_username.text = ""
		$Create/notification/Label.text = "username not taken"
	else:
		$Create/notification/Label.text = "username taken"
		
func username_check_results(results):
	if results:
		username_check = true
		$Create/notification/Label.text = "username not taken"
	else:
		$Create/notification/Label.text = "username taken"
	
func _on_UsernameCheck_pressed():
	check_button.disabled = true
	var username = username_field.text.strip_edges().strip_escapes()
	print ("inside usernamecheck pressed %s" % username)
	
	if string_validation(username):
		Server.check_usernames(get_instance_id(), username)
		check_button.disabled = false
		new_username = username
	
func created_character():
	widget_reset()
	populate_info()
	$Create/notification/Label.text = "successfully created character"
	username_field.clear()
	check_button.disabled = false
"""

func deleted_character():
	widget_reset()
	populate_info()
	notification.text = "successfully deleted character"
	$Delete.disabled = false
	
"""
func string_validation(username):
	if username.length() < 6:
		$Create/notification/Label.text = "username must be at least 6 characters"
		check_button.disabled = false
		return false
	for letter in username:
		if not letter in dictionary:
			$Create/notification/Label.text = "invalid username"
			check_button.disabled = false
			return false
	for banned_word in GameData.string_validation:
		if banned_word in username.to_lower():
			$Create/notification/Label.text = "contains inappropirate words"
			check_button.disabled = false
			return false
	return true
"""



func _on_New_pressed():
	create_button.disabled = true
	if Global.character_list.size() == 3:
		$Create/notification/Label.text = "you already have maximum amount of characters"
		create_button.disabled = false
	else:
		SceneHandler.change_scene("create")
