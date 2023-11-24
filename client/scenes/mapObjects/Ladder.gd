extends Area2D

func _on_Ladder_body_entered(body):
	if body.is_in_group("climber"):
		if body.can_climb == false:
			body.can_climb = true
			print(body.can_climb)
	pass

func _on_Ladder_body_exited(body):
	if !body.no_collision_zone:
		body.set_collision_layer_value(0, true)
		body.set_collision_mask_value(0, true)
	if body.is_in_group("climber"):
		if body.can_climb == true:
			body.can_climb = false
			print(body.can_climb)
	pass
