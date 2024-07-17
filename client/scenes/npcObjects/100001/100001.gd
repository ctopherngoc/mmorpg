extends Sprite

onready var id = "100001"
onready var data = GameData.npcTable[self.id]
onready var sprite = preload("res://assets/npcSprites/100001/100001.png")
onready var spriteW = preload("res://assets/npcSprites/100001/100001w.png")
onready var label = $Label
onready var anim = $AnimationPlayer
onready var dialog_index = 0
onready var dialog_bubble = $ChatBox
onready var dialog_timer = $DialogTimer

onready var dialog_box = preload("res://scenes/userInerface/Dialog.tscn")

#onready var can_interact = true
var clicked = false

func _ready() -> void:
	label.text = data.name
	dialog_timer.start()
	
func _on_Area2D_input_event(viewport, event, shape_idx) -> void:
	#if can_interact:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("popup dialog for npc")
#			clicked = true
#			var dialog = dialog_box.instance()
#			dialog.npc_id = self.id
#			dialog.chatDialog = data.chatDialog
#			self.add_child(dialog)
			Signals.emit_signal("toggle_dialog", self.id)
			

func move(location) -> void:
	#print(location)
	if location.x < position.x:
		self.flip_h = true
		self.texture = spriteW
		self.set_position(location)
	elif location.x > position.x:
		self.flip_h = false
		self.texture = spriteW
		self.set_position(location)
	else:
		self.texture = sprite

# keeps bubble open
func _on_DialogTimer_timeout():
	#print(dialog_bubble.rect_position)
	dialog_bubble.display_text(data.bubbleDialog[dialog_index])
	if dialog_index + 1 == data.bubbleDialog.size():
		dialog_index = 0
	else:
		dialog_index += 1

func _on_Area2D_mouse_entered():
	print("dectect mouse")

