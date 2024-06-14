extends Control

onready var quantity_popup = preload("res://scenes/menuObjects/PopupMenus/drop_quantity_popup.tscn")
onready var drop_confirm_popup = preload("res://scenes/menuObjects/PopupMenus/drop_confirm_popup.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var non_movable_windows = ["InGameMenu", "PlayerHUD", "ChatBox", "Control"]
onready var ui_nodes = {
	'player_stats': get_node("PlayerStats"),
	'inventory': get_node("Inventory"),
	'chat_box': $Control/ChatBox,
	'player_hud':  get_node("PlayerHUD"),
	"key_binds": get_node("KeyBinds")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.ui = self
	for window in get_children():
		if not window.name in non_movable_windows:
			print(window.name)
			window.connect('move_to_top', self, 'move_window_to_top')

func move_window_to_top(node):
	move_child(node, get_child_count() - 3)

"""
data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["item_data"] = item_data {id, name, q}
		data["from_slot"] = slot_index
		data["tab"] = tab
		"""
func drop_data(_pos, data):
	print("attempt dropped item")
	# dropping item from inventory
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
	
func can_drop_data(_pos, data):
	#print("in can drop data")
	return true

