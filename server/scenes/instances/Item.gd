extends KinematicBody2D
var id
var stats
var player_owner = null
var amount
var gravity = 800
var velocity = Vector2(0, 0)
var looted = false
var map
var drop_id
var stackable = 0
var just_dropped = 1

func _ready():
	pass

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

# player owner looting timer
func _on_Timer_timeout() -> void:
	player_owner = null

# existance timer
func _on_Timer2_timeout() -> void:
	just_dropped = -1

func _on_Area2D_area_entered(area: Area2D) -> void:

	if player_owner:
		if area.get_parent().name == player_owner:
			pass
	else:
		pass
