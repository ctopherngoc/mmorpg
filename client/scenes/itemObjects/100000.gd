extends Node2D
onready var looted = false
onready var animation_player = $AnimationPlayer

func _ready():
	pass
	animation_player.play("idle")
