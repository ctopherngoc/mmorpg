extends Area2D

func _on_Ladder_area_entered(area):
	if area.is_in_group("climber"):
# warning-ignore:unused_variable
		var parent = area.get_parent()

func _on_Ladder_area_exited(area):
	if area.is_in_group("climber"):
# warning-ignore:unused_variable
		var parent = area.get_parent()
