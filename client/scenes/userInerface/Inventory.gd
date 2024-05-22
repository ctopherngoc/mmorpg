extends Control

var inventory_slot = preload("res://scenes/userInerface/InventorySlot.tscn")
signal move_to_top

onready var use_grid = $Background/M/V/TabContainer/Use/ScrollContainer/GridContainer
onready var equip_grid = $Background/M/V/TabContainer/Equip/ScrollContainer/GridContainer
onready var etc_grid = $Background/M/V/TabContainer/ETC/ScrollContainer/GridContainer
onready var gold_label = $Background/M/V/ColorRect/HBoxContainer/goldLabel

# global.player
onready var inv_ref = {
	"100000": 0,
	"equipment": [],
	"use": [],
	"etc": [],
}
onready var stackable_tabs = ["etc", "use"]
onready var item_path= "res://assets/itemSprites/"
onready var max_slots = 32
onready var inventory_tabs
onready var initialize = 0
var drag_position = null

var node_list = {
	"etc": [],
	"use": [],
	"equipment": [],
}

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_inventory", self, "update_inventory")
	Signals.connect("toggle_inventory", self, "toggle_inventory")
	poplulate_inventory()
	"""
	update to own function instead of _Ready so it can be called by
	_ready and also when update inventory
	Drag and Drop Inventory System | Godot Tutorial
	https://www.youtube.com/watch?v=dZYlwmBCziM
	"""
	# scroll through tabs (equip, use, etc) notmade yet
func poplulate_inventory():
	# inventory_tabs can be changed to global.player.inventory
	inv_ref = Global.player.inventory
	for tab in inv_ref:
		if tab == "100000":
			gold_label.text = str(inv_ref[tab])
		else:
			var count = 0
			max_slots = inv_ref[tab].size()
			# for item in each tab
			while count < max_slots:
				var inv_slot_new = inventory_slot.instance()
				inv_slot_new.tab = tab
				inv_slot_new.slot_index = count
				# there is an item in data
				
				if inv_ref[tab][count] != null:
					var item = inv_ref[tab][count]
					var _item_name = GameData.itemTable[str(item['id'])]["itemName"]
					inv_slot_new.item_data["id"] = str(item['id'])
					inv_slot_new.item_data["item"] = GameData.itemTable[str(item['id'])]["itemName"]
					# if stackable exit number on iventory slot
					if tab in stackable_tabs:
						inv_slot_new.get_node("VBoxContainer/Label").text = str(item["q"])
						inv_slot_new.item_data["q"]= item["q"]
					if tab == "equipment":
						var temp_item_path = item_path + "equipItems/" + inv_ref[tab][count]["id"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						equip_grid.add_child(inv_slot_new, true)
					elif tab == "use":
						var temp_item_path = item_path + "useItems/" + inv_ref[tab][count]["id"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						use_grid.add_child(inv_slot_new, true)
					elif tab == "etc":
						var temp_item_path = item_path + "etcItems/" + inv_ref[tab][count]["id"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						etc_grid.add_child(inv_slot_new, true)
					node_list[tab].append(inv_slot_new)
				else:
					if tab == "equipment":
						equip_grid.add_child(inv_slot_new, true)
					elif tab == "use":
						use_grid.add_child(inv_slot_new, true)
					elif tab == "etc":
						etc_grid.add_child(inv_slot_new, true)
					node_list[tab].append(inv_slot_new)
				count += 1

func update_inventory():
	# inventory_tabs can be changed to global.player.inventory
	inv_ref = Global.player.inventory
	for tab in inv_ref:
		if tab == "100000":
			gold_label.text = str(inv_ref[tab])
		else:
			var count = 0
			max_slots = inv_ref[tab].size()
			# for item in each tab
			while count < max_slots:
				
				if inv_ref[tab][count] != null:
					# get item node from node_list
					var item = inv_ref[tab][count]
					var item_node = node_list[tab][count]
					#print("in update inventory, item: %s" % item)
					var _item_name = GameData.itemTable[str(item['id'])]["itemName"]
					item_node.item_data["id"] = str(item['id'])
					item_node.item_data["item"] = GameData.itemTable[str(item['id'])]["itemName"]
					# if stackable exit number on iventory slot
					if tab in stackable_tabs:
						item_node.label.text = str(item["q"])
						item_node.item_data["q"]= item["q"]
					if tab == "equipment":
						var temp_item_path = item_path + "equipItems/" + inv_ref[tab][count]["id"] + ".png"
						item_node.icon.texture = load(temp_item_path)
					elif tab == "use":
						var temp_item_path = item_path + "useItems/" + inv_ref[tab][count]["id"] + ".png"
						item_node.icon.texture = load(temp_item_path)
					elif tab == "etc":
						var temp_item_path = item_path + "etcItems/" + inv_ref[tab][count]["id"] + ".png"
						item_node.icon.texture = load(temp_item_path)
				else:
					var item_node = node_list[tab][count]
					item_node.item_data = {"id": null,"item": null, "q": null}
					item_node.icon.set_texture(null)
				count += 1

func _on_Header_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			print("left mouse button")
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position
			

"""
func update inventory

Required to add rpc calls to server to swap inventory data.
Server remove func to validate item move request -> 
update server char inventory data -> client remote func to update character data ->
 update inventory window icons (similar to health hud)
"""

func test_setup():
	inventory_tabs = inv_ref.keys()
	for key in inventory_tabs:
		if key != "100000":
			var count = 0
			while count < max_slots:
				inv_ref[key].append(null)
				count += 1
	#var inventory_tabs = Global.player.inventory.keys()
	#var inv_ref = Global.player.inventory
	inv_ref["use"][0] = {'id': "300001", 'q': 5}
	inv_ref["use"][1] = {'id': "300002", 'q': 500}
	inv_ref["use"][6] = {'id': "300003", 'q': 420}
	inv_ref["equipment"][1] = {'id': "500004"}
	inv_ref["equipment"][6] = {'id': "500005"}
	inv_ref["100000"] = 123456789


func _on_TabContainer_tab_selected(_tab):
	AudioControl.play_audio("menuClick")
	
func toggle_inventory():
	self.visible = not self.visible
