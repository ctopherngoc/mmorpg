extends Area2D

func _ready():
	$AnimationPlayer.play("portal")

func _input(event):
	if event.is_action_pressed("up"):
		if get_overlapping_bodies().size() > 0:
			print("initiating portal request to server")
			Server.portal(self.name)

func _on_Portal_area_entered(_area):
	print("player on portal")

func _on_Portal_area_exited(_area):
	print("player left portal")
