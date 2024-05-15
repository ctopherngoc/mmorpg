extends Position2D

onready var label = $Label
onready var tween = $Tween
var amount: String
var type: String

var velocity = Vector2(1,1)
var max_size = Vector2(1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(amount)
	
	match type:
		"Heal":
			label.set("custom_colors/font_color", Color("00ff15"))
		"Damage":
			label.set("custom_colors/font_color", Color("ffffff"))
		"Critical":
			max_size = Vector2(1.25,1.25)
			label.set("custom_colors/font_color", Color("00ffd5"))
	tween.interpolate_property(self, "scale", scale, max_size, 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#tween.interpolate_property(self, "scale", max_size,  Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()


func _process(delta):
	position -= velocity * delta
