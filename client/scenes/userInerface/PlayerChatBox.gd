extends MarginContainer

onready var label = $MarginContainer/VBoxContainer/message
onready var timer = $Timer
onready var  display_name: String = ""
const MIN_SIZE = Vector2(100, 36)


func _ready():
	self.rect_size = self.MIN_SIZE
	self.visible = false

func display_text(text_to_display: String):
	if text_to_display == "":
		pass
	else:
		#var text = text_to_display
		label.text = display_name + ": " + text_to_display
		timer.start()
		self.visible = true
		
func npc_display_text(text_to_display: String):
	#var text = text_to_display
	label.text = text_to_display
	timer.start()
	self.visible = true

func _on_Timer_timeout():
	self.visible = false
	label.text = ""
	self.rect_size = self.MIN_SIZE
