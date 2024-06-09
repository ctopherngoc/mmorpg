extends CenterContainer

onready var icon = $Icon
#onready var label_text = ""
onready var quantity_label = $Item/Quantity

func _ready():
	#$Label.text = label_text
	pass

func drop_data(_pos, data):
	print("attmepting to assign item to hotkey %s" % self.name)
	# if skill or if item
	if data.has("tab") and data.tab == "use":
		print("hotkey item %s" % data.item_data.id)
		quantity_label.text = str(data.item_data.q) + " "
		icon.texture = data["origin_texture"]
		
	elif data.has("skill_id"):
		print("hotkey skill %s" % data.skill_id)
		pass
	
func can_drop_data(_pos, data):
	print("in %s hotkey" % self.name)
	return true
