extends Panel

onready var data
onready var quantity_popup = preload("res://scenes/menuObjects/PopupMenus/drop_quantity_popup.tscn")

func _ready():
	pass

func _on_Button_pressed():
	print("dropping unqiue item")
	if GameData.itemTable[data.item_data.id].itemType == "equipment" or data.item_data.q == 1:
		Signals.emit_signal("drop_request", data.from_slot, data.tab, 1)
	else:
		var popup = quantity_popup.instance()
		popup.data = data
		self.get_parent().add_child(popup)
	self.queue_free()


func _on_Button2_pressed():
	print("not dropping item")
	self.queue_free()
