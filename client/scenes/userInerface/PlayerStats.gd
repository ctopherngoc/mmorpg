extends Control

var drag_position
signal move_to_top

onready var strength = get_node("HBoxContainer/VBoxContainer/Strength/Value")
onready var luck = get_node("HBoxContainer/VBoxContainer/Luck/Value")
onready var dexterity = get_node("HBoxContainer/VBoxContainer/Dexterity/Value")
onready var wisdom = get_node("HBoxContainer/VBoxContainer/Wisdom/Value")
onready var stat_points = get_node("HBoxContainer/VBoxContainer/StatPoints/ColorRect/Value")

onready var sp_buttons = [$HBoxContainer/VBoxContainer/Strength/Button, 
						$HBoxContainer/VBoxContainer/Luck/Button4,
						$HBoxContainer/VBoxContainer/Dexterity/Button3,
						$HBoxContainer/VBoxContainer/Wisdom/Button2,
						]

"""
add so that server does firebase request for 
"""

func _ready() -> void:
#	Server.fetch_player_stats()
	load_player_stats(Global.player.stats)
	# warning-ignore:return_value_discarded
	Signals.connect("update_stats", self, "update_display")
	Signals.connect("toggle_stats", self, "toggle_stats")

func load_player_stats(stats: Dictionary) -> void:
	strength.set_text(str(stats.base.strength + stats.equipment.strength))
	luck.set_text(str(stats.base.luck + stats.equipment.luck))
	dexterity.set_text(str(stats.base.dexterity + stats.equipment.dexterity))
	wisdom.set_text(str(stats.base.wisdom + stats.equipment.wisdom))
	stat_points.set_text(str(stats.base.sp))
	if stats.base.sp > 0:
		turn_on_buttons()
	else:
		turn_off_buttons()

func update_display() -> void:
	load_player_stats(Global.player.stats)
	if Global.player.stats.base.sp > 0:
		turn_on_buttons()
	else:
		turn_off_buttons()

func turn_on_buttons() -> void:
	for i in sp_buttons:
		i.visible = true

func turn_off_buttons() -> void:
	for i in sp_buttons:
		i.visible = false
	
func _on_PlayerStats_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func _on_Button2_pressed() -> void:
	AudioControl.play_audio("menuClick")
	if Global.player.stats.base.sp > 0:
		Global.player.stats.base.sp -= 1
		Global.player.stats.base.wisdom += 1
		Server.add_stat("w")


func _on_Button3_pressed() -> void:
	AudioControl.play_audio("menuClick")
	if Global.player.stats.base.sp > 0:
		Global.player.stats.base.sp -= 1
		Global.player.stats.base.dexterity += 1
		Server.add_stat("d")


func _on_Button_pressed() -> void:
	AudioControl.play_audio("menuClick")
	if Global.player.stats.base.sp > 0:
		Global.player.stats.base.sp -= 1
		Global.player.stats.base.strength += 1
		Server.add_stat("s")
		
func _on_Button4_pressed() -> void:
	AudioControl.play_audio("menuClick")
	if Global.player.stats.base.sp > 0:
		Global.player.stats.base.sp -= 1
		Global.player.stats.base.luck += 1
		Server.add_stat("l")

func toggle_stats() -> void:
	self.visible = not self.visible
