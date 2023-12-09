extends Area2D

func _on_Ladder_area_entered(area):
	print("over rope")
	if area.is_in_group("climber"):
		var parent = area.get_parent()
		if parent.can_climb == false:
			parent.can_climb = true
			print(parent.can_climb)


func _on_Ladder_area_exited(area):
	if area.is_in_group("climber"):
		var parent = area.get_parent()
		if parent.can_climb == true:
			parent.can_climb = false
			print(parent.can_climb)
