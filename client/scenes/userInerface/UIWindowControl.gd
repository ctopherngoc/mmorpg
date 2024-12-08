extends Control

onready var quantity_popup = preload("res://scenes/menuObjects/PopupMenus/drop_quantity_popup.tscn")
onready var drop_confirm_popup = preload("res://scenes/menuObjects/PopupMenus/drop_confirm_popup.tscn")
onready var fps_counter = $GameInfo/HBoxContainer/FPSCounter
onready var ping_counter = $GameInfo/HBoxContainer/PingCounter

var non_movable_windows = ["InGameMenu", "PlayerHUD", "ChatBox", "DebuggerWindow", "HotKeys", "ButtonBar", "GameInfo", "MessageBar"]
onready var ui_nodes = {
	'player_stats': get_node("PlayerStats"),
	'inventory': get_node("Inventory"),
	'chat_box': $ChatBox,
	'player_hud':  get_node("PlayerHUD"),
	"key_binds": get_node("KeyBinds"),
	#'hot_keys': $HotKeys,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.ui = self
	for window in get_children():
		if not window.name in non_movable_windows:
			print(window.name)
			window.connect('move_to_top', self, 'move_window_to_top')

func move_window_to_top(node):
	move_child(node, get_child_count() - non_movable_windows.size())

func _process(_delta):
	pass
"""
data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["item_data"] = item_data {id, name, q}
		data["from_slot"] = slot_index
		data["tab"] = tab
		"""
func drop_data(_pos, data):
	if data.has("item_data"):
		if not GameData.itemTable[data.item_data.id].droppable:
			print("are you sure you want to drop?")
			var drop_confirm =  drop_confirm_popup.instance()
			drop_confirm.data = data
			self.add_child(drop_confirm)
		elif data.item_data.q:
			print(data.item_data)
			if data.item_data.q > 1:
				print("popup more than 1 dropped")
				var new_quantity_popup = quantity_popup.instance()
				new_quantity_popup.data = data
				self.add_child(new_quantity_popup)
				#Server.drop_request(data.from_slot, data.tab, quantity)
			elif data.item_data.q == 0:
				print(data.item_data.q)
				print("dropping 0 quantity do nothing")
			else:
				Server.drop_request(data.from_slot, data.tab)
		else:
			print("dropping equipment")
			"""
			data["origin_node"] = self
			data["origin_texture"] = icon.texture
			data["item_data"] = item_data
			data["from_slot"] = slot_index
			data["tab"] = tab
			"""
			Server.drop_request(data.from_slot, data.tab)
	else:
		if data.keybind_data.id in GameData.mandatory_keys:
			print("emitting signal for attak")
			Signals.emit_signal("reset_default_keybind", data.keybind_data.id)
		data.origin_node.icon.texture = null
		data.origin_node.quantity_label.text = ""
		data.origin_node.hotkey_data = null
		data.origin_node.bg.texture = load(data.origin_node.empty_bg)
		Server.remove_keybind(data.origin_node.name)
	
# warning-ignore:unused_argument
func can_drop_data(_pos, data):
	#print("in can drop data")
	if data.has("slot"):
		return false
	return true

func _on_Timer_timeout():
	fps_counter.text = "FPS: %s" % Engine.get_frames_per_second()
	if Server.latency < 100:
		ping_counter.modulate = Color(0, 1, 0.217778)
	elif Server.latency > 500:
		ping_counter.modulate = Color(1, 0, 0)
	else:
		ping_counter.modulate = Color(255, 242, 0)
	ping_counter.text = "Ping: %sms" % str(Server.latency)

