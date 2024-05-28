extends Panel

onready var drop_button = $ColorRect/VBoxContainer/HBoxContainer2/Button
onready var quantity_error = $IncorrectQuantity
"""
data["origin_node"] = self
data["origin_texture"] = icon.texture
data["item_data"] = item_data
data["from_slot"] = slot_index
data["tab"] = tab
"""
onready var data
onready var button = $ColorRect/VBoxContainer/HBoxContainer2/Button
func _ready():
	$IncorrectQuantity.window_title = ""
	$IncorrectQuantity.get_child(1).align = HALIGN_CENTER
	
# drop_request(slot: int, tab: String, quantity: int = 1) 
func _on_Button_pressed():
	button.disabled = true
	var text = $ColorRect/VBoxContainer/HBoxContainer2/LineEdit.text
	if text.is_valid_integer():
		if int(text) <= data.item_data.q:
			Signals.emit_signal("drop_quantity", data.from_slot, data.tab, int(text))
			self.queue_free()
		else:
			quantity_error.show()
			# isnsert incorrect quantity popup
	else:
		quantity_error.show()
		
func _on_IncorrectQuantity_confirmed():
	button.disabled = false
