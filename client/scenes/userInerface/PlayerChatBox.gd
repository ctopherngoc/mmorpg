extends MarginContainer

onready var label = $MarginContainer/VBoxContainer/message
onready var timer = $Timer

onready var  display_name: String = ""
const MIN_SIZE = Vector2(116, 36)

func _ready():
	self.visible = false
	self.rect_size = self.MIN_SIZE

func display_text(text_to_display: String):
	if text_to_display == "":
		pass
	else:
		var text = text_to_display
		label.text = display_name + ": " + text_to_display
		timer.start()
		self.visible = true

func _on_Timer_timeout():
	self.visible = false
	label.text = ""
	self.rect_size = self.MIN_SIZE
