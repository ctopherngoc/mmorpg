extends Control

const sprite_location = "res://assets/npcSprites/%s/%s.png"

onready var avaliable_quests = $QuestLog/M/V/TabContainer/Avaliable/ScrollContainer/MarginContainer/VBoxContainer
onready var in_progress_quests = $QuestLog/M/V/TabContainer/InProgress/ScrollContainer/MarginContainer/VBoxContainer
onready var completed_quests = $QuestLog/M/V/TabContainer/Completed/ScrollContainer/MarginContainer/VBoxContainer

onready var quest_info = $QuestInfo
onready var quest_info_name = $QuestInfo/M/V/Header/ColorRect/VBoxContainer/QuestName
onready var quest_info_level = $QuestInfo/M/V/Header/ColorRect/VBoxContainer/LevelReq
onready var quest_info_descrption = $QuestInfo/M/V/ColorRect/MarginContainer/VBoxContainer/Description
onready var quest_info_npc_texture = $QuestInfo/M/V/Header/ColorRect/Sprite
onready var quest_info_objective = $QuestInfo/M/V/ColorRect/MarginContainer/VBoxContainer/Objective

onready var quest_entry = preload("res://scenes/userInerface/InGameUI/QuestEntry.tscn")
onready var drag_position


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_quest_log", self, "populate_quest_log")
# warning-ignore:return_value_discarded
	Signals.connect("toggle_quest_details", self, "toggle_quest_details")
# warning-ignore:return_value_discarded
	Signals.connect("toggle_questLog", self, "toggle_questLog")
	populate_quest_log()

func _on_Header_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			#print("left mouse button")
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position


func _on_TabContainer_tab_selected(_tab):
	pass # Replace with function body.

func populate_quest_log():
	for child in avaliable_quests.get_children():
		child.queue_free()
	for child in in_progress_quests.get_children():
		child.queue_free()
	for child in completed_quests.get_children():
		child.queue_free()
	var index = 0
	for quest in Global.quest_data:
		if not GameData.questTable[str(index)].preReq == null:
			#print("this quest has a prereq %s" % str(index))
			if not Global.quest_data[GameData.questTable[str(index)].preReq][0] == 9:
				#print("this pre req is not completed")
				index +=1
				continue
		
		var new_entry = quest_entry.instance()
		new_entry.text = GameData.questTable[str(index)].title
		new_entry.quest_id = index
		new_entry.quest_data = GameData.questTable[str(index)]
		# not started
		if quest[0] == -1:
			avaliable_quests.add_child(new_entry)
			
		# finished	
		elif quest[0] == 9:
			completed_quests.add_child(new_entry)
		# started but not finished
		else:
			in_progress_quests.add_child(new_entry)
		index += 1
		
func toggle_quest_details(quest_id, quest_data: Dictionary):
	# update texture
	quest_info_npc_texture.texture = load(sprite_location % [str(quest_data.npcStart), str(quest_data.npcStart)])
	# update quest name
	quest_info_name.text = str(quest_data.title)
	# update quest level
	quest_info_level.text = str("Level: %s" % str(quest_data.levelReq))
	# update description
	quest_info_descrption.text = str(quest_data.description)
	quest_info_objective.text = str(quest_data.objective)
	# update objective
	if quest_data.type == "hunt":
		var index = 0
		var hunted_list = Global.quest_data[int(quest_id)][1]
		for hunted in hunted_list:
			quest_info_objective.text += "\n%s/%s %s" % [str(hunted), str(quest_data.questReq[index+1]), GameData.monsterTable[str(quest_data.questReq[index])].title] 
			index += 2
	# make panel visible
	if quest_info.visible == false:
		quest_info.visible = true

func _on_ToggleInfo_pressed():
	quest_info.visible = false

func toggle_questLog() -> void:
	self.visible = not self.visible
