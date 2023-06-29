extends Camera2D

func _ready():
	pass

func _process(_delta):
	if Input.is_action_pressed("1"):
		global_position = Vector2(512, -301)
	
	elif Input.is_action_pressed("2"):
		global_position = Vector2(1788, -300)
	else:
		pass
