extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if Input.is_action_pressed("1"):
		#global_position = Vector2(481, -279)
		global_position = Vector2(512, -301)
	
	elif Input.is_action_pressed("2"):
		global_position = Vector2(1788, -300)
	else:
		pass
