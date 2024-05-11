extends Node


onready var bgm = $bgm/bgm
onready var menu = $menu

onready var stream_dict = {
	"menuClick": $menu/click,
	"menuHover": $menu/hover,
	"itemSwap": $menu/item_swap,
	"windowToggle": $menu/window_toggle,
	"squish": $combat/squish,
	"1h_swing": $combat/blade_swing,
	"2h_swing": $combat/h_blade_swing,
	"blunt_swing": $combat/blunt_swing,
	"h_blade_hit": $combat/h_blade_hit,
	"portal": $map/portal,
	"drop": $map/drop,
	"loot": $map/loot,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_audio(audio: String) -> void:
	stream_dict[audio].play()
