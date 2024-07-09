extends Sprite

onready var id
onready var dialogue

onready var label = $Label
onready var anim = $AnimationPlayer


onready var can_interact = true
var clicked = false

func _ready():
	pass

func _on_Area2D_input_event(viewport, event, shape_idx):
	if can_interact:
		if event is InputEventMouseButton and clicked == false:
			clicked = true
			print("popup dialog for npc")
#			var dialog = DIALOG.instance()s
#			Global.ui.add_child(dialog)
#			Global.movable = false
			

func move(location):
	if location.x < position.x:
		self.flip_h == true
	elif location.x > position.x:
		self.flip_h = false
	else:
		pass
