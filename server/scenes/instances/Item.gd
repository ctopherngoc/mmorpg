extends KinematicBody2D
var id
var stats
var player_owner
var amount
var gravity = 800
var velocity = Vector2(0, 0)

func _ready():
	pass

func _process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

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
