extends Control

var drag_position = null
signal move_to_top

onready var empty_bg = "res://assets/UI/background/hotkey_background.png"
onready var active_bg = "res://assets/UI/backgroundSource/Red.png"

onready var keybind_list = {
	'esc': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/esc,
	'f1': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f1,
	'f2': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f2,
	'f3': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f3,
	'f4': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f4,
	'f5': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f5,
	'f6': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f6,
	'f7': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f7,
	'f8': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f8,
	'f9': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f9,
	'f10': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f10,
	'f11': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f11,
	'f12': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer/f12,
	'tilda': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/`",
	'1': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/1",
	'2': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/2",
	'3': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/3",
	'4': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/4",
	'5': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/5", 
	'6': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/6", 
	'7': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/7", 
	'8': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/8", 
	'9': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/9", 
	'0': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/0", 
	'-': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/-", 
	'=': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/=",
	"backspace": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/backspace,
	'tab': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/tab,
	'q': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/q, 
	'w': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/w, 
	'e': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/e, 
	'r': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/r, 
	't': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/t, 
	'y': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/y, 
	'u': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/u, 
	'i': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/i, 
	'o': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/o, 
	'p': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/p, 
	'[': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/[", 
	']': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/]", 
	"backslash": $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/\\",
	'caplock': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/cap,
	'a': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/a,
	's': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/s, 
	'd': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/d, 
	'f': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/f, 
	'g': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/g, 
	'h': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/h, 
	'j': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/j, 
	'k': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/k, 
	'l': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/l, 
	';': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/;", 
	"'": $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/\'",
	'enter': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer4/enter,
	'lshift': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/lshift, 
	'z': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/z, 
	'x': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/x, 
	'c': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/c, 
	'v': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/v, 
	'b': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/b, 
	'n': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/n, 
	'm': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/m, 
	',': $"NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/,", 
	'.': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/dot, 
	'forwardslash': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/fowardslash,
	"rshift": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/rshift,
	'rctrl': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/rctrl,
	"win": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/win,
	'ralt': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/ralt, 
	'space': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/space,
	'lalt': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/lalt,
	'fn': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/fn,
	'lctrl': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/lctrl,
	 'ins': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/ins,
	'home': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/home, 
	'pgup': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer2/pgup, 
	'del': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/del, 
	'end': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/end, 
	'pgdn': $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer3/pgdwn,
	"up": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer5/up,
	"down": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/down,
	"left": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/left,
	"right": $NinePatchRect/MarginContainer/VBoxContainer/HBoxContainer/SetKeyBinds/GridContainer6/right,
	}
	
onready var default_keybind_nodes = {
	"attack": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/attack,
	"loot": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/loot,
	"stat": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/stat,
	"skill": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/skill,
	"inventory": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/inventory,
	"equipment": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/equipment,
	#"test": $NinePatchRect/MarginContainer/VBoxContainer/UnsetKeyBinds/VBoxContainer/GridContainer/test,
	}

onready var unbound_default_keybind = []
	
onready var default_keybind_key = {
	"backslash": "keybind",
	"lalt": "jump",
	"ralt": "jump",
	"esc": "menu",
	
	}
onready var hotkey_list = ['shift', 'ins', 'home', 'pgup', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'ctrl', 'del', 'end', 'pgdn', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12']

func _ready():
	for key in default_keybind_nodes.keys():
		unbound_default_keybind.append(key)
	# warning-ignore:return_value_discarded
	Signals.connect("toggle_keybinds", self, "toggle_keybinds")
	populate_key_labels()

func toggle_keybinds() -> void:
	self.visible = not self.visible

func _on_KeyBinds_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			#print("left mouse button")
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func populate_key_labels() -> void:
	for key in keybind_list.keys():
		if "ctrl" in key:
			keybind_list[key].label.text = "ctrl"
			keybind_list[key].key = "ctrl"
		elif "shift" in key:
			keybind_list[key].label.text = "shift"
			keybind_list[key].key = "shift"
		elif "alt" in key:
			keybind_list[key].label.text = "alt"
			keybind_list[key].key = "alt"
		elif key == "tilda":
			keybind_list[key].label.text = "`"
# warning-ignore:unused_variable
			var temp_bg = keybind_list[key].bg.texture
			keybind_list[key].key = "`"
		elif key == "forwardslash":
			keybind_list[key].label.text = "/"
			keybind_list[key].key = "/"
		elif key == "backslash":
			keybind_list[key].label.text = "'\'"
			keybind_list[key].key = "'\'"
		elif key == "dot":
			keybind_list[key].label.text = "."
			keybind_list[key].key = "."
		elif key == "backspace":
			keybind_list[key].label.text = "back"
			keybind_list[key].key = "backspace"
		else:
			keybind_list[key].label.text = key
			keybind_list[key].key =  str(key)
		if key in ['ralt', 'lalt', 'esc', 'backslash', "caplock"]:
			keybind_list[key].bg.texture = to_gray_scale(load(empty_bg))
	
	for key in default_keybind_nodes.keys():
		if key == "inventory":
			default_keybind_nodes[key].label.text = "inv"
		elif key == "equipment":
			default_keybind_nodes[key].label.text = "equip"
		else:
			#print(key)
			default_keybind_nodes[key].label.text = key
		default_keybind_nodes[key].label.rect_min_size = Vector2(30,30)
		
func to_gray_scale(texture):
	var image: = Image.new()
	image = texture.get_data()
	image.lock()
	for x in texture.get_size().x:
		for y in texture.get_size().y:
			var current_pixel = image.get_pixel(x,y)
			if current_pixel.a == 1:
				current_pixel = current_pixel.gray()
				var new_color = Color.from_hsv(0, 0, current_pixel)
				image.set_pixel(x, y, new_color)
	image.unlock()
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	return image_texture

func populate_keybinds(keybinds: Dictionary) -> void:
	# itterate through each keybind in dictionary
	for key in keybinds.keys():
		# if key not null
		
		if keybinds[key]:
			print(key)
			# if key is in UnsetKeyBinds box
			if keybinds[key] in default_keybind_nodes.keys():
				default_keybind_nodes[keybinds[key]].label.visible = false
				#default_keybind_nodes[keybinds[key]].hotkey_data = null
				unbound_default_keybind.erase(keybinds[key])
				
				if key == "ctrl":
					print("ctrl")
					keybind_list["rctrl"].quantity_label.text = keybinds[key]
					keybind_list["rctrl"].quantity_label.align = 0
					keybind_list["rctrl"].quantity_label.clip_text = true
					keybind_list["rctrl"].bg.texture = load(active_bg)
					keybind_list["lctrl"].quantity_label.text = keybinds[key]
					keybind_list["lctrl"].quantity_label.align = 0
					keybind_list["lctrl"].quantity_label.clip_text = true
					keybind_list["rctrl"].bg.texture = load(active_bg)
					"""
					set keyind data
					"""
				else:
					if keybinds[key] == "inventory":
						keybind_list[key].quantity_label.text = "inv"
						#keybind_list[key].hotkey_data = {"id": "inventory"}
					elif keybinds[key] == "equipment":
						keybind_list[key].quantity_label.text = "equip"
						#keybind_list[key].hotkey_data = {"id": "equipment"}
					else:
						keybind_list[key].quantity_label.text = keybinds[key]
					keybind_list[key].hotkey_data = {"id": key}
					keybind_list[key].quantity_label.align = 0
					keybind_list[key].quantity_label.clip_text = true
					keybind_list[key].bg.texture = load(active_bg)
					
			# skill or item
			else:
				if keybind_list[key].is_valid_integer():
						if keybind_list[key] in GameData.skill_class_dictionary:
							pass
							# get skill location
							
							# get skill icon
							
							# set skill icon teture
						elif keybind_list[key] in GameData.item:
							pass
							
							# get item data
							
							# get item location
							
							# get item quantity
							
							# load quantity
							
							# load item icon texture
						else:
							pass
		else:
			if key == "shift":
				keybind_list["rshift"].bg.texture = load(empty_bg)
				keybind_list["rshift"].hotkey_data = null
				keybind_list["lshift"].bg.texture = load(empty_bg)
				keybind_list["lshift"].hotkey_data = null
			elif key == "ctrl":
				keybind_list["rctrl"].bg.texture = load(empty_bg)
				keybind_list["rctrl"].hotkey_data = null
				keybind_list["lctrl"].bg.texture = load(empty_bg)
				keybind_list["lctrl"].hotkey_data = null
			elif key == "`":
				keybind_list["tilda"].bg.texture = load(empty_bg)
				keybind_list["tilda"].hotkey_data = null
			elif key == "/":
				keybind_list["forwardslash"].bg.texture = load(empty_bg)
				keybind_list["forwardslash"].hotkey_data = null
			else:
				keybind_list[key].bg.texture = load(empty_bg)
				keybind_list[key].hotkey_data = null
				
	#print(unbound_default_keybind)
	for key in unbound_default_keybind:
		default_keybind_nodes[key].label.visible = true
#
#func update_from_hotkey(key, key_data) -> void:
#	pass
