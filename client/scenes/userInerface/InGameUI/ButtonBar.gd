extends Panel


func _ready():
	pass


func _on_Stat_pressed():
	Signals.emit_signal("toggle_stats")


func _on_Skill_pressed():
	Signals.emit_signal("toggle_stats")


func _on_Inventory_pressed():
	Signals.emit_signal("toggle_inventory")


func _on_Equipment_pressed():
	Signals.emit_signal("toggle_equipment")
	


func _on_Keybind_pressed():
	Signals.emit_signal("toggle_keybinds")
	

func _on_Option_pressed():
	Signals.emit_signal("toggle_options")
	
