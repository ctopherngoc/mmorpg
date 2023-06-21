#extends Area2D
#
#export(Vector2) var endLocation
#
#
#func _read():
#	pass
#
#
#func teleport(location):
#	print(location)
#	player.global_position = endLocation
#
#
#func _on_Teleporter_body_entered(body):
#	if body.is_in_group("player"):
#		players.append(body)
#		player = body
#		print(players)
#
#func _on_Teleporter_body_exited(body):
#	players.erase(body)
#	player = null
#	print(players)
