extends CenterContainer

onready var icon = $Icon
onready var label = $Label
onready var quantity_label = $Item/Quantity
onready var item = $Item
onready var hotkey_data
onready var bg = $TextureRect
onready var bg_texture = "res://assets/UI/background/hotkey_background.png"

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("reset_default_keybind", self, "reset_default_keybind")
	Signals.connect("key_in_use", self, "key_in_use")
	
	pass

func get_drag_data(_pos):
	if label.visible:
		#print("yesyes")
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["id"] =  self.name
		data["type"] = "keybind"
	
	
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
		
		return data

func drop_data(_pos, data):
	if GameData.mandatory_keys.has(data.id):
		pass

# warning-ignore:unused_argument
func can_drop_data(_pos, data):
	return false

func update_hotkey() -> void:
	if not self.name in GameData.mandatory_keys:
		if Global.player.keybind[self.name] == null:
			icon.texture = null
			hotkey_data = null
			quantity_label.text = ""
		else:
			var id = Global.player.keybind[self.name]
			#print("id: %s" % id)
			
			if GameData.skill_class_dictionary.has(str(id)):
				icon.texture = load(GameData.skill_class_dictionary[str(id)].icon)
				hotkey_data = {"id": str(id)}
				quantity_label.text = ""
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

func reset_default_keybind(keybind: String) -> void:
	if self.name == keybind:
		label.visible = true

func key_in_use(keybind: String) -> void:
	if self.name == keybind:
		label.visible = false
