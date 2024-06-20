extends CenterContainer
onready var type = "keybind"
onready var icon = $Icon
#onready var label_text = ""
onready var quantity_label = $Item/Quantity
onready var hotkey_data
onready var empty_bg = "res://assets/UI/background/hotkey_background.png"
onready var active_bg = "res://assets/UI/background/hotkey_background_used.png"
onready var bg = get_node("TextureRect")

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("update_keybinds", self, "update_hotkey")

func get_drag_data(_pos):
	#dragging = true
	# if slot is not null
	#if Global.player.inventory[tab][slot_index] != null:
	if Global.player.keybind[self.name]:
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		if GameData.skill_class_dictionary.has(str(Global.player.keybind[self.name])):
			data["skill_data"] = {"id": str(Global.player.keybind[self.name])}
		elif GameData.mandatory_keys.has(self.name):
			print(self.name)
			print("inside hotkey.gd get_drag_data")
			print("skipping -> need to implement keys layout menu")
			return
		else:
			data["item_data"] = {"tab": "use", "q": quantity_label.text, "id": hotkey_data.id}
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = icon.texture
		drag_texture.rect_size = Vector2(50, 50)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data

func drop_data(_pos, data):
	print("attmepting to assign item to hotkey %s" % self.name)
	if hotkey_data:
		# make copy of current data
		var destination_data = hotkey_data
		
		# change icons
		data.origin_node.icon.texture = icon.texture
		icon.texture = data["origin_texture"]
		
		# change current hotkey
		if data.has("item_data"):
			hotkey_data = data["item_data"]
			quantity_label.text = str(data.item_data.q) + " "
			
		elif data.has("skill_data"):
			hotkey_data = data["skill_data"]
			quantity_label.text = ""
		print("hotkey %s skill %s" % [self.name, hotkey_data.id])
		
		# origin hotkey
		if destination_data.has("item_data"):
			data.origin_node.hotkey_data = destination_data["item_data"]
			data.origin_node.quantity_label.text = str(destination_data.item_data.q)
			
		elif destination_data.has("skill_data"):
			data.origin_node.hotkey_data = destination_data["skill_data"]
			data.origin_node.quantity_label = ""
		print("hotkey %s skill %s" % [data.origin_node.name, data.origin_node.hotkey_data.id])
		
		Server.swap_keybind(self.name, data.origin_node.name)
		
		# change original slot
	else:
		bg.texture = load(active_bg)
		# if skill or if item
		if data.has("item_data"):
			hotkey_data = data["item_data"]
			quantity_label.text = str(data.item_data.q) + " "
			icon.texture = data["origin_texture"]
			Server.update_keybind(self.name, "use", data.item_data.id)
			
		elif data.has("skill_data"):
			hotkey_data = data["skill_data"]
			print("hotkey skill %s" % data.skill_data.id)
			icon.texture = data["origin_texture"]
			Server.update_keybind(self.name, "skill", data.skill_data.id)
	
# warning-ignore:unused_argument
func can_drop_data(_pos, data):
	print("in %s hotkey" % self.name)
	return true

func update_hotkey() -> void:
	if Global.player.keybind[self.name] == null:
		icon.texture = null
		hotkey_data = null
		quantity_label.text = ""
		bg.texture = load(empty_bg)
	else:
		bg.texture = load(active_bg)
		var id = Global.player.keybind[self.name]
		print("id: %s" % id)
		
		if GameData.skill_class_dictionary.has(str(id)):
			#var skill_path = "res://assets/itemSprites/useItems/" + id + ".png"
			#var skill_path = "res://assets/skillSprites/0/icon.png"
			icon.texture = load(GameData.skill_class_dictionary[str(id)].icon)
			hotkey_data = {"id": str(id)}
			quantity_label.text = ""
			
		elif id in GameData.mandatory_keys:
			print("mandatory keys: %s" % id)
			quantity_label.text = str(id) + " "
		else:
			# set item texture
			var item_path = "res://assets/itemSprites/useItems/" + id + ".png"
			icon.texture = load(item_path)
			hotkey_data = {"id": id}
			# find quantity
			for item in Global.player.inventory.use:
				if item and item.id == id:
					quantity_label.text = str(item.q) + " "
					hotkey_data["q"] = item.q
					return
			hotkey_data["q"] = 0
			quantity_label = "0"

