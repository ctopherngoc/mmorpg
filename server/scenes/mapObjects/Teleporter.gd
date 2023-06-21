extends Area2D

export(Vector2) var endLocation

"""
currently teleporter saves body as a singular variable.
1. should append to list -> if action press up on teleporter is body in list
2. body.global_position = end destination
3.remove body from list (on exit)
"""

onready var players = []
onready var player

func _read():
	pass


## E 0:00:38.146   event_get_action_status: The InputMap action "up" doesn't exist. Did you mean "ui_up"?
func _input(event):
	if event.is_action_pressed("ui_up"):
		
		if get_overlapping_bodies().size() > 0:
			#print(get_overlapping_bodies())
			#print("event: ", event)
			teleport(endLocation)
		
func teleport(location):
	print(location)
	player.global_position = endLocation
	

func _on_Teleporter_body_entered(body):
	if body.is_in_group("player"):
		players.append(body)
		player = body
		print(players)

func _on_Teleporter_body_exited(body):
	players.erase(body)
	player = null
	print(players)
