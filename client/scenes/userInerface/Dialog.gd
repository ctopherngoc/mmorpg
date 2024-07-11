extends Control

const sprite_location = "res://assets/npcSprites/%s/%s.png"

onready var quest_label = preload('res://scenes/userInerface/DialogQuestText.tscn')
onready var npc_sprite = $Background/MarginContainer/V/HBoxContainer/NPC_Box/Sprite
onready var npc_name = $Background/MarginContainer/V/HBoxContainer/NPC_Box/Sprite/Label
onready var dialog = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/VBoxContainer/DialogContainer/MarginContainer/RichTextLabel
onready var reply_v_box = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/VBoxContainer/ReplyContainer/MarginContainer/VBoxContainer/QuestVBox
onready var test_npc_id

#BUTTONS
onready var back_button = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/VBoxContainer/ReplyContainer/MarginContainer/VBoxContainer/ButtonHbox/back
onready var next_button = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/VBoxContainer/ReplyContainer/MarginContainer/VBoxContainer/ButtonHbox/next
onready var exit_button = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/ButtonContainer/HBoxContainer/exit
onready var accept_button = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/ButtonContainer/HBoxContainer/accept
onready var decline_button = $Background/MarginContainer/V/HBoxContainer/VBoxContainer2/ButtonContainer/HBoxContainer/decline

onready var chatDialog
onready var chatIndex = 0
onready var questDialog = []
onready var questIndex = 0
#onready var questDialogBool = false

onready var test_quest_data = {"100000": {"name": "Bobert","chatDialog": "You look like you need some trainning tips!",}}
onready var test_quest_server_array = [9,9,-1,-1]
onready var test_questTable

func _ready():
	Signals.connect("load_quest_dialog", self, "load_quest_dialog")
	Signals.connect("next_quest_dialog", self, "next_quest_dialog")
	Signals.connect("prev_quest_dialog", self, "prev_quest_dialog")
	Signals.connect("accept_quest_dialog", self, "accept_quest_dialog")
	Signals.connect("refuse_quest_dialog", self, "refuse_quest_dialog")
	var data_file = File.new()
	data_file.open("res://data/GameDataTable.json", File.READ)
	var gamedata_json = JSON.parse(data_file.get_as_text())
	test_questTable = gamedata_json.result["QuestTable"]	
	data_file.close()
	
	test_npc_id = "100000"
	chatDialog = test_quest_data[test_npc_id].chatDialog
	#chatDialog = GameData.NPCTable[test_npc_id].chatDialog
	fill_dialog_box()

func _on_exit_pressed():
	print("queuefree dialog box")
	self.queue_free()
	#Signals.emit_signal("dialog_closed")

func _on_accept_pressed():
	accept_quest_dialog()
	print("accept quest")


func _on_decline_pressed():
	refuse_quest_dialog()
	print("decline quest")
	
func fill_dialog_box() -> void:
	# fill in sprite
	npc_sprite.texture  = load(sprite_location % [test_npc_id, test_npc_id])
	# fill in sprite name 
	npc_name.text = test_quest_data[test_npc_id].name
	#npc_name.text = GameData.NPCTable[test_npc_id].name
	# fill in first index of dialog
	if chatIndex == 0:
		dialog.text = chatDialog
		var quest_keys = test_questTable.keys()
		
		var index = 0
		for quest in test_quest_server_array:
			# if quest not completed
			if quest < 9:
				#print(test_quest_server_array[index], " ", test_questTable[str(index)])
				#print(typeof(test_quest_server_array[index]), " ", typeof(test_questTable[str(index)]))
				# if quest not started and npcStart is current noc
				if test_quest_server_array[index] == -1 and str(test_questTable[str(index)].npcStart) == test_npc_id:
					# if has prequest
					if test_questTable[str(index)].preReq:
						# if NOT prequest completed
						if not test_quest_server_array[int(test_questTable[str(index)].preReq)] == 9:
							index += 1
							continue
						var new_quest = quest_label.instance()
						new_quest.quest_id = index
						new_quest.text = str(test_questTable[str(index)].title + " (start)")
						reply_v_box.add_child(new_quest)
						index += 1
					else:
						index += 1
						
				elif quest > -1 and test_questTable[str(index)].npcEnd == test_npc_id:
					var new_quest = quest_label.instance()
					new_quest.quest_id = index
					new_quest.text = str(test_questTable[str(index)].title + " (complete)")
					reply_v_box.add_child(new_quest)
					index += 1
					# load window about finishing
				else:
					index += 1 
			else:
				index += 1
	# fill in active/avaliable quests
	# update buttons
	update_buttons()

func update_buttons() -> void:
	# if dialog just open
	if chatIndex == 0:
		back_button.visible = false
		accept_button.visible = false
		next_button.visible = false
		decline_button.visible = false
	else:
		if questIndex == 0:
			next_button.visible = true
			back_button.visible = true
		elif questIndex == questDialog.size() - 3:
			print("we are here")
			back_button.visible = true
			accept_button.visible = true
			decline_button.visible = true
			next_button.visible = false
		elif questIndex < questDialog.size() - 3:
			back_button.visible = true
			next_button.visible = true
		elif questIndex == questDialog.size() - 2 or questIndex == questDialog.size() - 1:
			back_button.visible = false
			accept_button.visible = false
			next_button.visible = false
			decline_button.visible = false
		#elif chatIndex > 0
		
func load_quest_dialog(quest_id):
	print(quest_id)
	for children in reply_v_box.get_children():
		children.queue_free()
	if test_quest_server_array[quest_id] == -1:
		questDialog = test_questTable[str(quest_id)].startDialog
		chatIndex = 1
		dialog.text = questDialog[questIndex]
	else:
		questDialog = test_questTable[str(quest_id)].turnInDialog
	update_buttons() 
		
func next_quest_dialog():
	questIndex += 1
	print(questIndex)
	dialog.text = questDialog[questIndex]
	update_buttons() 

func prev_quest_dialog():
	if questIndex == 0:
		print(questIndex)
		chatIndex = 0
		fill_dialog_box()
	else:
		questIndex -= 1
		print(questIndex)
		dialog.text = questDialog[questIndex]
	update_buttons() 
	
func accept_quest_dialog():
	questIndex += 1
	dialog.text = questDialog[questIndex]
	update_buttons()
	print("send rpc call to server to accept quest")
	
func refuse_quest_dialog():
	questIndex += 2
	dialog.text = questDialog[questIndex]
	update_buttons() 


func _on_next_pressed():
	next_quest_dialog()


func _on_back_pressed():
	prev_quest_dialog()
