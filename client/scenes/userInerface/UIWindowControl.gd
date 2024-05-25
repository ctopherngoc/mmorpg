extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var non_movable_windows = ["InGameMenu", "PlayerHUD", "ChatBox", "Control"]
onready var ui_nodes = {
	'player_stats': get_node("PlayerStats"),
	'inventory': get_node("Inventory"),
	'chat_box': $Control/ChatBox,
	'player_hud':  get_node("PlayerHUD")
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
		data["item_data"] = item_data
		data["from_slot"] = slot_index
		data["tab"] = tab
		"""
func drop_data(_pos, data):
	print("dropped item")
	# dropping item from inventory
	if not GameData.itemTable[data.item_data.id].droppable:
		print("are you sure you want to drop?")
		var drop_bool = true
		
		if drop_bool:
			Server.drop_request(data.from_slot, data.tab)
			# maybe add quantity check here for stackable
		else:
			print("no drop unique item")
	else:
		if data.q != 1:
			if data.q > 1:
				print("popup more than 1 dropped")
				var quantity = 10
				Server.drop_request(data.from_slot, data.tab, quantity)
			else:
				print("dropping 0 quantity do nothing")
		else:
			print("dropping 1 quantity of item")
			"""
			data["origin_node"] = self
			data["origin_texture"] = icon.texture
			data["item_data"] = item_data
			data["from_slot"] = slot_index
			data["tab"] = tab
			"""
			Server.drop_request(data.from_slot, data.tab)
			
	"""
	
		-> popup are you sure
	else:
		if data.item_data.item.type != equipment and data.item_data.q > 1:
			-> how many you wanna drop
				-> grab quantity Q
			Server.drop_request(data.item_data, data.tab, data.tab, Q)
		# if equipment or quantity of 1
		else:
			Server.drop_request(data.item_data, data.tab, data.tab)
			
	"""
	
func can_drop_data(_pos, data):
	print("in can drop data")
	return true
	# check if we can drop item into slow
	# if slot is null -> move item
#	if item_data.id == null:
#		return true
#	else:
#		if data.tab == tab:
#			#data['origin_node'].get_node("ItemInfo").free()
#			return true
#		else:
#			#data['origin_node'].get_node("ItemInfo").free()
#			return false
