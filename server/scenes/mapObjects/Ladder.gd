extends Area2D

func _on_Ladder_body_entered(body):
	if body.is_in_group("climber"):
		if body.climbing == false:
			body.climbing = true
			print(body.climbing)
	pass
	
func _on_Ladder_body_exited(body):
	if !body.noColZone:
		body.set_collision_layer_bit(0, true)
		body.set_collision_mask_bit(0, true)
	if body.is_in_group("climber"):
		if body.climbing == true:
			body.climbing = false
			print(body.climbing)
	pass
