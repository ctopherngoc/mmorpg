extends Control
#video
# https://www.youtube.com/watch?v=-vDNk7BzOGc#onready var http: HTTPRequest = $HTTPRequest# onready var characterName : LineEdit = $CharacterBox/Character1/Container/CharacterName/LineEdit
onready var level : LineEdit = $CharacterBox/Character1/Container/Level/LineEdit
onready var notification : Label = $SceneTitle/notification/Label
var new_profile := false
var information_sent := false

onready var checkButton = $Create/UsernameCheck
onready var createButton = $Create/Create
onready var usernameField = $Create/usernameField
onready var dictionary = "ABCDEFGHIJKLMOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
onready var charCount
var displayName
#var playerInfo = Chrisndubs.playerInfo2
var newUsername
var username_check
	
func _ready():
	populateCharacterInfo()

func _process(_delta):
	pass
	
func populateCharacterInfo():
	createButton.disabled = false
	if Global.character_list.empty():
		notification.text = "No Character Found"
	else:
		var size = Global.character_list.size()
		#print("size: %s" % str(size))
		charCount = size
		if size >= 1:
			$CharacterBox/Character1.visible = true
			$CharacterBox/Character1/Container/CharacterName/LineEdit.text = str(Global.character_list[0]["displayname"])
			$CharacterBox/Character1/Container/Level/LineEdit.text = str(Global.character_list[0]["stats"]["level"])
			$CharacterBox/Character1.character_info = Global.character_list[0]
			#$CharacterBox/Character1/Button1.visible = true
		if size >= 2:
			$CharacterBox/Character2.visible = true
			$CharacterBox/Character2/Container/CharacterName/LineEdit.text = str(Global.character_list[1]["displayname"])
			$CharacterBox/Character2/Container/Level/LineEdit.text = str(Global.character_list[1]["stats"]["level"])
			$CharacterBox/Character2.character_info = Global.character_list[1]
			#$CharacterBox/Character2/Button2.visible = false
		if size == 3:
			createButton.disabled = true
			$CharacterBox/Character3.visible = true
			$CharacterBox/Character3/Container/CharacterName/LineEdit.text = str(Global.character_list[2]["displayname"])
			$CharacterBox/Character3/Container/Level/LineEdit.text = str(Global.character_list[2]["stats"]["level"])
			$CharacterBox/Character3.character_info = Global.character_list[2]
			#$CharacterBox/Character3/Button3.visible = false
		notification.text = "Profile Loaded"

	
func _load_userData():
	pass
	
func charWdigetReset():
	$CharacterBox/Character1.visible = false
	$CharacterBox/Character2.visible = false
	$CharacterBox/Character3.visible = false
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = false
	$CharacterBox/Character3/ColorRect.visible = false

func _on_Button1_pressed():
	$CharacterBox/Character1/ColorRect.visible = true
	Global.player = Global.character_list[0]
	if charCount == 2:
		$CharacterBox/Character2/ColorRect.visible = false
	if charCount == 3:
		$CharacterBox/Character2/ColorRect.visible = false
	#print(Global.player)
	
func _on_Button2_pressed():
	Global.player = Global.character_list[1]
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = true
	if charCount == 3:
		$CharacterBox/Character3/ColorRect.visible = false
	#print(Global.player)


func _on_Button3_pressed():
	Global.player = Global.character_list[2]
	$CharacterBox/Character1/ColorRect.visible = false
	$CharacterBox/Character2/ColorRect.visible = false
	$CharacterBox/Character3/ColorRect.visible = true
	#print(Global.player)

func _on_Select_pressed():
	$Select.disabled = true
	if Global.player:
		#print(Global.player['lastmap'])
		Server.ChooseCharacter(get_instance_id(), Global.player['displayname'])
		# call method to signal server global.player is chosen as active character to spawn
	else:
		$Select.disabled = false
		
func EnterMap():
	#print("entering map")
	SceneHandler.changeScene(Global.player['lastmap']) 

func _on_Delete_pressed():
	print('Attempting to delete selected character')
	$Delete.disabled = true
	Server.deleteCharacter(get_instance_id(), Global.player['displayname'])

func _on_Create_pressed():
	#check for username check bool
	createButton.disabled = true
	if Global.character_list.size() == 3:
		$Create/notification/Label.text = "you already have maximum amount of characters"
		createButton.disabled = false
	elif username_check and usernameField.text == newUsername:
		if stringValidation(newUsername):
			Server.createCharacter(get_instance_id(), newUsername)
	else:
		$Create/notification/Label.text = "check username availability"
		createButton.disabled = false

func createCharacter(results):
	if results:
		populateCharacterInfo()
		newUsername.text = ""
		$Create/notification/Label.text = "username not taken"
	else:
		$Create/notification/Label.text = "username taken"
		
func returnUsernameCheck(results):
	if results:
		username_check = true
		$Create/notification/Label.text = "username not taken"
	else:
		$Create/notification/Label.text = "username taken"
	
func _on_UsernameCheck_pressed():
	checkButton.disabled = true
	var username = usernameField.text.strip_edges().strip_escapes()
	print ("inside usernamecheck pressed %s" % username)
	
	if stringValidation(username):
		Server.checkUsernames(get_instance_id(), username)
		checkButton.disabled = false
		newUsername = username
	
func successfulCreatedChar():
	charWdigetReset()
	populateCharacterInfo()
	$Create/notification/Label.text = "successfully created character"
	usernameField.clear()
	checkButton.disabled = false
	
func successfulDeleteChar():
	charWdigetReset()
	populateCharacterInfo()
	notification.text = "successfully deleted character"
	$Delete.disabled = false

func stringValidation(username):
	if username.length() < 6:
		$Create/notification/Label.text = "username must be at least 6 characters"
		checkButton.disabled = false
		return false
	for letter in username:
		if not letter in dictionary:
			$Create/notification/Label.text = "invalid username"
			checkButton.disabled = false
			return false
	for bannedWord in Global.stringValidation:
		if bannedWord in username.to_lower():
			$Create/notification/Label.text = "contains inappropirate words"
			checkButton.disabled = false
			return false
	return true
