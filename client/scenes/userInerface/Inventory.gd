extends Control

var inventory_slot = preload("res://scenes/userInerface/InventorySlot.tscn")

onready var use_grid = $Background/M/V/TabContainer/Use/ScrollContainer/GridContainer
onready var equip_grid = $Background/M/V/TabContainer/Equip/ScrollContainer/GridContainer
onready var etc_grid = $Background/M/V/TabContainer/ETC/ScrollContainer/GridContainer
onready var inv_ref = {
	"equipment": [],
	"use": [],
	"etc": [],
}
onready var max_slots = 32
onready var inventory_tabs
# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_tabs = inv_ref.keys()
	for key in inventory_tabs:
		var count = 0
		while count < max_slots:
			inv_ref[key].append(null)
			count += 1
		print(inv_ref[key])
	#var inventory_tabs = Global.player.inventory.keys()
	#var inv_ref = Global.player.inventory
	
	
	# scroll through tabs (equip, use, etc) notmade yet
	for tab in inventory_tabs:
		print(tab)
		var count = 0
		# for item in each tab
		while count < max_slots:
			#for item in inv_ref[tab]:
			var inv_slot_new = inventory_slot.instance()
			# there is an item in data
			#if item["itemID"] != null:
			if inv_ref[tab][count] != null:
				var item = inv_ref[tab][count]
				var item_name = GameData.ItemTable[str(item["itemID"])]["itemName"]
				#var item_name = GameData.ItemTable[str(item["itemID"])]["itemName"]
				#var icon_texture = load()
				
				# if stackable
				if item["amount"] != null:
					pass
					inv_slot_new.get_node("RichTextLabel").text = str(item["amount"])
				#inv_slot_new.get_node("Icon").set_texture(icon_texture)
			if tab == "equipment":
				equip_grid.add_child(inv_slot_new, true)
			elif tab == "use":
				use_grid.add_child(inv_slot_new, true)
			elif tab == "etc":
				etc_grid.add_child(inv_slot_new, true)
			count += 1
		print(inv_ref[tab].size())
