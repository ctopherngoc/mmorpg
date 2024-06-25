extends Position2D

onready var label = $Label
onready var tween = $Tween
var amount: String
var type: String
onready var timer = $Timer

var velocity = Vector2(1,1)
var max_size = Vector2(1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(amount)
	match type:
		"PH":
			label.set("custom_colors/font_color", Color("00ff15"))
			#yield(get_tree().create_timer(1.0),"timeout")
			#self.queue_free()
#			var start_position = self.position
#			var end_postion = Vector2(0, -50) + start_position
#			tween.interpolate_property(self, "scale", scale, max_size, 1.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
#			tween.interpolate_property(self, "position", start_position, end_postion, 1.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
#			tween.start()
		"N":
			label.set("custom_colors/font_color", Color("ffffff"))
			#yield(get_tree().create_timer(1.0),"timeout")
			#self.queue_free()
		"C":
			label.set("custom_colors/font_color", Color("00ffd5"))
			#yield(get_tree().create_timer(1.0),"timeout")
			#self.queue_free()
		"M":
			label.set("custom_colors/font_color", Color("9700ff"))
			#yield(get_tree().create_timer(1.0),"timeout")
			#self.queue_free()
		"PN":
			label.set("custom_colors/font_color", Color("f90000"))
			#yield(get_tree().create_timer(1.0),"timeout")
			#self.queue_free()
	timer.start()
	
func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	position -= velocity * delta


func _on_Timer_timeout():
	self.queue_free()
