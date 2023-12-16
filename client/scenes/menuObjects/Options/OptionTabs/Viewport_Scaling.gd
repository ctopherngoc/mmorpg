extends Viewport


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	set_size(get_tree().get_root().get_size())

func _on_Video_ViewPortScale(scale: Vector2):
	set_size(scale)

func _on_Video_ViewPortSizeChange(NewSize):
	set_size(NewSize)
