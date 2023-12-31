extends Node2D
var id
var stats
var player_owner

func _ready():
	pass
## warning-ignore:return_value_discarded
#	$Area2D.connect("area_entered", self, "on_area_entered")
## warning-ignore:return_value_discarded
#	$Area2D.connect("area_exited", self, "on_area_exited")
	
#func on_area_entered(_area2d):
#	player = true
#
#func on_area_exited(_area2d):
#	player = false
#
#func _process(_delta):
#	if player == true:
#		if (Input.is_action_pressed("loot")):
#			$AnimationPlayer.play("pickup")

func _on_Area2D_body_entered(body):
	if player_owner:
		if body.name == player_owner:
			pass
	else:
		pass

# player owner looting timer
func _on_Timer_timeout():
	player_owner = null

# existance timer
func _on_Timer2_timeout():
	self.queue_free()
