extends Control

var inventory_slot = preload("res://scenes/userInerface/InventorySlot.tscn")
signal move_to_top

onready var use_grid = $Background/M/V/TabContainer/Use/ScrollContainer/GridContainer
onready var equip_grid = $Background/M/V/TabContainer/Equip/ScrollContainer/GridContainer
onready var etc_grid = $Background/M/V/TabContainer/ETC/ScrollContainer/GridContainer
onready var gold_label = $Background/M/V/ColorRect/HBoxContainer/goldLabel
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
var drag_position = null

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_tabs = inv_ref.keys()
	for key in inventory_tabs:
		if key != "100000":
			var count = 0
			while count < max_slots:
				inv_ref[key].append(null)
				count += 1
	#var inventory_tabs = Global.player.inventory.keys()
	#var inv_ref = Global.player.inventory
	inv_ref["use"][0] = {'i': "300001", 'q': 5}
	inv_ref["use"][1] = {'i': "300002", 'q': 500}
	inv_ref["use"][6] = {'i': "300003", 'q': 420}
	inv_ref["equipment"][1] = {'i': "500004"}
	inv_ref["equipment"][6] = {'i': "500005"}
	inv_ref["100000"] = 123456789
	
	
	"""
	update to own function instead of _Ready so it can be called by
	_ready and also when update inventory
	Drag and Drop Inventory System | Godot Tutorial
	https://www.youtube.com/watch?v=dZYlwmBCziM
	"""
	# scroll through tabs (equip, use, etc) notmade yet
	for tab in inventory_tabs:
		if tab == "100000":
			gold_label.text = str(inv_ref[tab])
		else:
			var count = 0
			# for item in each tab
			while count < max_slots:
				var inv_slot_new = inventory_slot.instance()
				inv_slot_new.tab = tab
				inv_slot_new.slot_index = count
				# there is an item in data
				if inv_ref[tab][count] != null:
					var item = inv_ref[tab][count]
					var item_name = GameData.itemTable[str(item['i'])]["itemName"]
					inv_slot_new.item_data["id"] = str(item['i'])
					inv_slot_new.item_data["item"] = GameData.itemTable[str(item['i'])]["itemName"]
					# if stackable exit number on iventory slot
					if tab in stackable_tabs:
						inv_slot_new.get_node("VBoxContainer/Label").text = str(item["q"])
						inv_slot_new.item_data["q"]= item["q"]
					if tab == "equipment":
						var temp_item_path = item_path + "equipItems/" + inv_ref[tab][count]["i"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						equip_grid.add_child(inv_slot_new, true)
					elif tab == "use":
						var temp_item_path = item_path + "useItems/" + inv_ref[tab][count]["i"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						use_grid.add_child(inv_slot_new, true)
					elif tab == "etc":
						var temp_item_path = item_path + "etcItems/" + inv_ref[tab][count]["i"] + ".png"
						inv_slot_new.get_node("Icon").texture = load(temp_item_path)
						etc_grid.add_child(inv_slot_new, true)
				else:
					if tab == "equipment":
						equip_grid.add_child(inv_slot_new, true)
					elif tab == "use":
						use_grid.add_child(inv_slot_new, true)
					elif tab == "etc":
						etc_grid.add_child(inv_slot_new, true)
				count += 1

func _input(event):
	if event.is_action_pressed("inventory"):
		self.visible = not self.visible
		print("toggle inventory")

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
