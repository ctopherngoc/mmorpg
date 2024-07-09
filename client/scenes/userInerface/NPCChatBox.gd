extends MarginContainer

onready var label = $MarginContainer/VBoxContainer/message
onready var timer = $Timer
const MIN_SIZE = Vector2(100, 36)

func _ready():
	self.rect_size = self.MIN_SIZE
	self.visible = false

func display_text(text_to_display: String):
	var text = text_to_display
	label.text = text_to_display
	timer.start()
	self.visible = true

func _on_Timer_timeout():
	self.visible = false
	label.text = ""
	#self.rect_size = self.MIN_SIZE
	#self.rect_position.y = -104
