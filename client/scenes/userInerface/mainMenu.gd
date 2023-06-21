extends Node
# https://www.youtube.com/watch?v=XHbrKdsZrxY


func _on_RegisterButton_pressed() -> void:
	SceneHandler.changeScene(SceneHandler.scenes["register"])

func _on_LoginButton_pressed() -> void:
	SceneHandler.changeScene(SceneHandler.scenes["login"])
