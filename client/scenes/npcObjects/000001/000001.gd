extends Area2D
var can_interact = false
const diaglog = false
var clicked = false

func _physics_process(_delta):
	$AnimatedSprite.play()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_mouse_entered():
	can_interact = true
	print("can interact")


func _on_Area2D_mouse_exited():
	can_interact = false
	print("cannot interact")


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	#print(event)
	if event is InputEventMouseButton:
		print("clicked")

func _on_Area2D_area_entered(area):
	print(area)# Replace with function body.
