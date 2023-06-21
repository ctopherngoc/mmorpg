extends Area2D

#export(String, FILE, "*.tscn, *.scn") var target_scene

func _read():
	pass

func _input(event):
	if event.is_action_pressed("up"):
#		if !target_scene:
#			print("no scene")
#			return
		if get_overlapping_bodies().size() > 0:
			print("initiating portal request to server")
			Server.Portal(self.name)
		
#func next_level():
##	print(target_scene)
##	SceneHandler.changeScene(target_scene)
##	var ERR = SceneHandler.changeScene(target_scene)
##	print(ERR)
##	if ERR != OK:
##		print("something failed in door scene")
##
##		return
#	#Global.undate_lastmap(target_scene)
#	Global.door_name = name


func _on_Portal_area_entered(_area):
	print("player on portal")



func _on_Portal_area_exited(_area):
	print("player left portal")
