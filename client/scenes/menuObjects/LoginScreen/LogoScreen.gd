extends Control


onready var login_scene = preload("res://scenes/menuObjects/LoginScreen/LoginScreen.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$AnimationPlayer.play("dissolve logo")
	$Timer2.start()


func _on_Timer2_timeout():
	$AnimationPlayer.play("dissolve")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "dissolve":
		SceneHandler.change_scene("login")
