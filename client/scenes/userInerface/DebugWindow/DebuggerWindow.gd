extends Control

onready var label = $Label
func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	if Global.in_game:
		label.text = str(Global.player.stats.base.movementSpeed + Global.player.stats.equipment.movementSpeed + Global.player.stats.buff.movementSpeed)
