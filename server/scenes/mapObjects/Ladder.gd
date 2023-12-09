extends Area2D

func _on_Ladder_area_entered(area):
	if area.is_in_group("climber"):
		var parent = area.get_parent()
		if parent.can_climb == false:
			Global.send_climb_data(self.name, 1)
			parent.can_climb = true


func _on_Ladder_area_exited(area):
	if area.is_in_group("climber"):
		var parent = area.get_parent()
		if parent.can_climb == true:
			Global.send_climb_data(self.name, 0)
			parent.can_climb = false
