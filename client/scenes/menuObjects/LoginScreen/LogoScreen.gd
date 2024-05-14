extends Control


onready var login_scene = preload("res://scenes/menuObjects/LoginScreen/LoginScreen.tscn")

func _ready() -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, linear2db(0.40))

func _on_Timer_timeout() -> void:
	$AnimationPlayer.play("dissolve logo")
	$PreAudio.play()
	$Timer2.start()

func _on_Timer2_timeout() -> void:
	$AnimationPlayer.play("dissolve")
	$PostAudio.play()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "dissolve":
		SceneHandler.change_scene("login")
