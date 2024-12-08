extends CenterContainer

onready var icon = $Icon
onready var label = $Label
onready var quantity_label = $Item/Quantity
onready var item = $Item
onready var bg = $TextureRect

onready var hotkey_data
onready var key

onready var empty_bg = "res://assets/UI/background/hotkey_background.png"
onready var active_bg = "res://assets/UI/background/hotkey_background_used.png"


func _ready():
	# warning-ignore:return_value_discarded
	pass
	Signals.connect("update_keybinds", self, "update_hotkey")

func get_drag_data(_pos):
	if Global.player.keybind[key]:
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		
		# if mantadtory
		if GameData.mandatory_keys.has(Global.player.keybind[key]):
			data["keybind_data"] = {"id": str(Global.player.keybind[key])}
			
			var drag_texture = TextureRect.new()
			drag_texture.expand = true
			drag_texture.modulate = Color(0,0,0,20)
			drag_texture.rect_size = Vector2(32, 32)
			
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
			drag_label.rect_position = -0.5 * drag_label.rect_size
			set_drag_preview(control)
		
		else:
			# if skill
			if GameData.skill_class_dictionary.has(str(Global.player.keybind[key])):
				data["skill_data"] = {"id": str(Global.player.keybind[key])}
				
			# if item
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

func can_drop_data(position, data):
	if data.has("keybind_data") or data.has("item_data") or data.has("skill_data"):
		return true
	else:
		return false
		
func drop_data(_pos, data):
	print("attmepting to assign item to hotkey %s" % key)
	if hotkey_data:
		
		if data.origin_node == self:
			#print("same node")
			return
		# make copy of current data
		var destination_data = hotkey_data
		
		# change icons
		data.origin_node.icon.texture = icon.texture
		icon.texture = data["origin_texture"]
		
		data.origin_node.hotkey_data = destination_data
		data.origin_node.quantity_label = ""

		print("hotkey %s skill %s" % [key, hotkey_data.id])
		
		# origin hotkey
		if destination_data.has("item_data"):
			data.origin_node.hotkey_data = destination_data["item_data"]
			data.origin_node.quantity_label.text = str(destination_data.item_data.q)
			
		elif destination_data.has("skill_data"):
			data.origin_node.hotkey_data = destination_data["skill_data"]
			data.origin_node.quantity_label.text = ""
			
		# mandatory keybind
		else:
			data.origin_node.hotkey_data = destination_data["keybind_data"]
			data.origin_node.quantity_label.text = ""
		
		print("hotkey %s skill %s" % [data.origin_node.name, data.origin_node.hotkey_data.id])
		
		if data.has("keybind_data"):
			Server.swap_keybind(key, data.origin_node.key)
		else:
			Server.swap_keybind(key, data.origin_node.name)
		
	# change original slot
	else:
		bg.texture = load(active_bg)
		# if skill or if item
		if data.has("item_data"):
			hotkey_data = data["item_data"]
			quantity_label.text = str(data.item_data.q) + " "
			icon.texture = data["origin_texture"]
			Server.update_keybind(key, "use", data.item_data.id)
			
		elif data.has("skill_data"):
			hotkey_data = data["skill_data"]
			print("hotkey skill %s" % data.skill_data.id)
			icon.texture = data["origin_texture"]
			Server.update_keybind(key, "skill", data.skill_data.id)
		
		else:
			hotkey_data = data["keybind_data"]
			print("hotkey keybind %s" % data.keybind_data.id)
			icon.texture = data["origin_texture"]
			Server.update_keybind(key, "keybind", data.keybind_data.id)

func update_hotkey() -> void:
	if not key or not Global.player.keybind.has(key):
		return
		
	if Global.player.keybind[key] == null:
		icon.texture = null
		hotkey_data = null
		quantity_label.text = ""
		bg.texture = load(empty_bg)
	else:
		bg.texture = load(active_bg)
		var id = Global.player.keybind[key]
		#print("id: %s" % id)
		
		# skill
		if GameData.skill_class_dictionary.has(str(id)):
			#var skill_path = "res://assets/itemSprites/useItems/" + id + ".png"
			#var skill_path = "res://assets/skillSprites/0/icon.png"
			icon.texture = load(GameData.skill_class_dictionary[str(id)].icon)
			hotkey_data = {"id": str(id)}
			quantity_label.text = ""
		
		# mando key
		elif id in GameData.mandatory_keys:
			#print("mandatory keys: %s" % id)
			if id == "inventory":
				quantity_label.text = str("inv") + " "
				#hotkey_data = {"id": "inventory"}
				#Signals.emit_signal("key_in_use", "inv")
			elif id == "equipment":
				quantity_label.text = str("equip") + " "
				#hotkey_data = {"id": "equipment"}
				#Signals.emit_signal("key_in_use", "equip")
			else:
				quantity_label.text = str(id) + " "
				#hotkey_data = {"id": str(id)}
				#Signals.emit_signal("key_in_use", id)
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

#func can_drop_data(_pos, data):
#	if data.has("keybind_data") or data.has("spell_data"):
#		return true
#	else:
#		return false
