extends Node2D
var player = false
var rng = RandomNumberGenerator.new()
var value = rng.randi_range(40, 51)

func _ready():
# warning-ignore:return_value_discarded
	$Area2D.connect("area_entered", Callable(self, "on_area_entered"))
# warning-ignore:return_value_discarded
	$Area2D.connect("area_exited", Callable(self, "on_area_exited"))
	
func on_area_entered(_area2d):
	player = true

func on_area_exited(_area2d):
	player = false
	
func _process(_delta):
	if player == true:
		if (Input.is_action_pressed("loot")):
			$AnimationPlayer.play("pickup")
			print(str(value) + " coins")
