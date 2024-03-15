extends KinematicBody2D
var id
var stats
var player_owner
var amount
var gravity = 800
var velocity = Vector2(0, 0)
var looted = false
var map

func _ready():
	pass

func _process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

# player owner looting timer
func _on_Timer_timeout():
	print(self.name, " no owner")
	player_owner = null

# existance timer
func _on_Timer2_timeout():
	print(self.name, " discard item")
	self.queue_free()


func _on_Area2D_area_entered(area):
	print("detect player")
	if player_owner:
		print(area.get_parent().name)
		if area.get_parent().name == player_owner:
			print("drop owner")
	else:
		pass
