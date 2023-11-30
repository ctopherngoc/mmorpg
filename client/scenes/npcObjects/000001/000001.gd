extends Area2D
var can_interact = false
const DIALOG = preload("res://scenes/userInerface/Dialog.tscn")
var clicked = false
var id = "Kevin"
var sprite = "res://scenes/npcObjects/000001/sprite/stand1_0.png"

func _physics_process(_delta):
	$AnimatedSprite.play()
# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("dialog_closed", self, "dialog_closed")

func dialog_closed():
	clicked = false
	print("dialog should be closed and kevin should be clickable")

func _on_Area2D_mouse_entered():
	can_interact = true
	print("can interact with kevin")


func _on_Area2D_mouse_exited():
	can_interact = false
	print("cannot interact with kevin")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	#print(event)
	if can_interact:
		if event is InputEventMouseButton and clicked == false:
			clicked = true
			print("popup dialog for npc")
			var dialog = DIALOG.instance()
			Global.ui.add_child(dialog)
			Global.movable = false
			

func _on_Area2D_area_entered(area):
	print(area)# Replace with function body.
