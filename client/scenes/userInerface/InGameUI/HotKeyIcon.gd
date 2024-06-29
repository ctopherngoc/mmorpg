extends CenterContainer

onready var icon = $Icon
onready var quantity_label = $Item/Quantity
onready var bg = $TextureRect
onready var label = $Label

onready var hotkey_data

onready var empty_bg = "res://assets/UI/background/hotkey_background.png"
onready var active_bg = "res://assets/UI/background/hotkey_background_used.png"

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("update_keybinds", self, "update_hotkey")

func get_drag_data(_pos):
	if Global.player.keybind[self.name]:
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		
		# if mantadtory
		if GameData.mandatory_keys.has(Global.player.keybind[self.name]):
			data["keybind_data"] = {"id": str(Global.player.keybind[self.name])}
			
			var drag_texture = TextureRect.new()
			drag_texture.expand = true
			drag_texture.texture = icon.texture
			drag_texture.rect_size = Vector2(50, 50)
			#drag_texture.modulate = Color(0,0,0,155)
			
			var drag_label = Label.new()
			drag_label.text = self.label.text
			drag_label.align = 1
			drag_label.valign = 0
			var dynamic_font = DynamicFont.new()
			dynamic_font.font_data = load("res://assets/fonts/droid-sans/DroidSans.ttf")
			drag_label.add_font_override("font", dynamic_font)
			dynamic_font.size = 10
			drag_label.rect_size = Vector2(32,32)
			
			var control = Control.new()
			control.add_child(drag_texture)
			control.add_child(drag_label)
			drag_texture.rect_position = -0.5 * drag_texture.rect_size
			set_drag_preview(control)
		
		else:
			# if skill
			if GameData.skill_class_dictionary.has(str(Global.player.keybind[self.name])):
				data["skill_data"] = {"id": str(Global.player.keybind[self.name])}
			
			# else item
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
	if hotkey_data:
		if data.origin_node == self:
			print("same node")
			return
		# make copy of current data
		var destination_data = hotkey_data
		
		# change icons
		data.origin_node.icon.texture = icon.texture
		icon.texture = data["origin_texture"]
		
		# change current hotkey
		if data.has("item_data"):
			print("attmepting to assign item to hotkey %s" % self.name)
			hotkey_data = data["item_data"]
			quantity_label.text = str(data.item_data.q) + " "
			
		elif data.has("skill_data"):
			hotkey_data = data["skill_data"]
			quantity_label.text = ""
		# mandatory key
		else:
			hotkey_data = data["keybind_data"]
			quantity_label.text = str(data.keybind_data.id) + " "

		print("destination_data: %s" % destination_data)
		# origin hotkey
		data.origin_node.hotkey_data = destination_data
		data.origin_node.quantity_label.text = ""
		
		print("hotkey %s skill %s" % [data.origin_node.name, data.origin_node.hotkey_data.id])
		
		if data.origin_node.get_parent().is_in_group("keybind"):
			Server.swap_keybind(self.name, data.origin_node.key)
		elif data.origin_node.get_parent().is_in_group("unsetkeybinds"):
			Server.swap_keybind(self.name, data.origin_node.key)
		else:
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
		
		else:
			print(data.keybind_data)
			hotkey_data = data["keybind_data"]
			quantity_label.text = str(data.keybind_data.id) + " "
			print("hotkey keybind %s" % data.keybind_data.id)
			icon.texture = data["origin_texture"]
			
			if not data.origin_node.is_in_group("unsetkeybinds"):
				data.origin_node.hotkey_data = null
				data.origin_node.quantity_label.text = ""
				data.origin_node.bg.texture = load(empty_bg)
				
			Server.update_keybind(self.name, "keybind", data.keybind_data.id)
	
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
		
		# skill
		if GameData.skill_class_dictionary.has(str(id)):
			#var skill_path = "res://assets/itemSprites/useItems/" + id + ".png"
			#var skill_path = "res://assets/skillSprites/0/icon.png"
			icon.texture = load(GameData.skill_class_dictionary[str(id)].icon)
			hotkey_data = {"id": str(id)}
			quantity_label.text = ""
		
		# mando key
		elif id in GameData.mandatory_keys:
			print("mandatory keys: %s" % id)
			if id == "inventory":
				quantity_label.text = str("inv") + " "
			elif id == "equipment":
				quantity_label.text = str("equip") + " "
			else:
				quantity_label.text = str(id) + " "
			
			hotkey_data = {"id": str(id)}
			Signals.emit_signal("key_in_use", id)

		# item
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
			quantity_label.text = "0"

