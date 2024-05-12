extends Node


onready var bgm = $bgm/bgm
onready var menu = $menu

onready var stream_dict = {
	"menuClick": $menu/click,
	"menuHover": $menu/hover,
	"itemSwap": $menu/item_swap,
	"windowToggle": $menu/window_toggle,
	"squish": $combat/squish,
	"deathSquish": $combat/death_squish,
	"deathSquish2": $combat/death_squish2,
	"levelUp": $combat/level_up,
	"1h_swing": $combat/blade_swing,
	"2h_swing": $combat/h_blade_swing,
	"blunt_swing": $combat/blunt_swing,
	"h_blade_hit": $combat/h_blade_hit,
	"portal": $map/portal,
	"drop": $map/drop,
	"loot": $map/loot,
	"jump": $map/jump,
	"typing": $menu/typing 
}

var jump_bool: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# added bool check for jump audio
# can cause unlimited stream plays because of 60 ticks/s on phtiscs
func play_audio(audio: String) -> void:
	if audio == "jump":
		if not jump_bool:
			jump_bool = not jump_bool
			stream_dict[audio].play()
	else:
		stream_dict[audio].play()

func _on_jump_finished():
	jump_bool = not jump_bool
