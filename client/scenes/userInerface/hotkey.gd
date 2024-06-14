extends CenterContainer

onready var icon = $Icon
#onready var label_text = ""
onready var quantity_label = $Item/Quantity

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("update_keybinds", self, "update_hotkey")

func drop_data(_pos, data):
	print("attmepting to assign item to hotkey %s" % self.name)
	# if skill or if item
	if data.has("tab") and data.tab == "use":
		print("hotkey item %s" % data.item_data.id)
		quantity_label.text = str(data.item_data.q) + " "
		icon.texture = data["origin_texture"]
		Server.update_keybind(self.name, "use", data.item_data.id)
		
	elif data.has("skill_data"):
		print("hotkey skill %s" % data.skill_data.id)
		icon.texture = data["origin_texture"]
		Server.update_keybind(self.name, "skill", data.skill_data.id)
	
func can_drop_data(_pos, data):
	print("in %s hotkey" % self.name)
	return true

func update_hotkey() -> void:
	if Global.player.keybind[self.name] == null:
		icon.texture = null
	else:
		var id = Global.player.keybind[self.name]
		
		if id in GameData.skill_class_dictionary.keys():
			#var skill_path = "res://assets/itemSprites/useItems/" + id + ".png"
			var skill_path = "res://assets/skillSprites/0/icon.png"
			icon.texture = load(skill_path)
		else:
			# set item texture
			var item_path = "res://assets/itemSprites/useItems/" + id + ".png"
			icon.texture = load(item_path)
			
			# find quantity
			for item in Global.player.inventory.use.keys():
				if Global.player.inventory.use[item].id == id:
					quantity_label = Global.player.inventory.use[item].q
					return
			quantity_label = "0"

