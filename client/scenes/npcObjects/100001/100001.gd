extends Sprite

onready var id = "100000"
onready var data = GameData.npcTable[self.id]
onready var sprite = preload("res://assets/npcSprites/100000/100000.png")
onready var label = $Label
onready var anim = $AnimationPlayer
onready var dialog_index = 0
onready var dialog_bubble = $ChatBox
onready var dialog_timer = $DialogTimer

onready var can_interact = true
var clicked = false

func _ready() -> void:
	label.text = data.name
	dialog_timer.start()
	
func _on_Area2D_input_event(viewport, event, shape_idx) -> void:
	if can_interact and not clicked:
		if event is InputEventMouseButton:
			print("popup dialog for npc")
			clicked = true

# keeps bubble open
func _on_DialogTimer_timeout():
	print(dialog_bubble.rect_position)
	dialog_bubble.display_text(data.chatDialog[dialog_index])
	if dialog_index + 1 == data.chatDialog.size():
		dialog_index = 0
	else:
		dialog_index += 1

func _on_Area2D_mouse_entered():
	print("dectect mouse")

