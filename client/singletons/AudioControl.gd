extends Node


onready var bgm = $bgm/bgm
onready var menu = $menu

onready var stream_dict = {
	"menuClick": $menu/click,
	"menuHover": $menu/hover,
	"itemSwap": $menu/item_swap,
	"windowToggle": $menu/window_toggle,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_audio(audio: String) -> void:
	stream_dict[audio].play()
