extends Sprite

onready var id = "100000"
onready var data = GameData.npcTable[self.id]
onready var sprite = preload("res://assets/npcSprites/100000/100000.png")
onready var label = $Label
onready var anim = $AnimationPlayer
onready var dialog_index = 0
onready var dialog_bubble = $ChatBox
onready var dialog_timer = $DialogTimer
onready var test_questTable
onready var test_npcTable

onready var dialog_box = preload("res://scenes/userInerface/Dialog.tscn")

onready var can_interact = true
var clicked = false

func _ready() -> void:
	Signals.connect("npc_click_false", self, "npc_click_false")
	label.text = data.name
	dialog_timer.start()
	var data_file = File.new()
	data_file.open("res://data/GameDataTable.json", File.READ)
	var gamedata_json = JSON.parse(data_file.get_as_text())
	test_questTable = gamedata_json.result["QuestTable"]
	test_npcTable = gamedata_json.result["NPCTable"]
	data_file.close()
	
func _on_Area2D_input_event(viewport, event, shape_idx) -> void:
	if can_interact and not clicked:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				print("popup dialog for npc")
				clicked = true
				var dialog = dialog_box.instance()
				dialog.npc_id = "100001"
				dialog.chatDialog = test_npcTable[self.name].chatDialog
				self.add_child(dialog)

# keeps bubble open
func _on_DialogTimer_timeout():
	pass
#	print(dialog_bubble.rect_position)
#	dialog_bubble.display_text(data.chatDialog[dialog_index])
#	if dialog_index + 1 == data.chatDialog.size():
#		dialog_index = 0
#	else:
#		dialog_index += 1

func _on_Area2D_mouse_entered():
	print("dectect mouse")
	
func npc_click_false() -> void:
	self.clicked = false

