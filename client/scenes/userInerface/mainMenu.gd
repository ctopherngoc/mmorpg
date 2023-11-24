extends Node

func _on_RegisterButton_pressed() -> void:
	SceneHandler.change_scene_to_file(SceneHandler.scenes["register"])

func _on_LoginButton_pressed() -> void:
	SceneHandler.change_scene_to_file(SceneHandler.scenes["login"])
