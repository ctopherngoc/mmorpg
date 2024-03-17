extends Control

var inventory_slot = preload("res://scenes/userInerface/InventorySlot.tscn")

onready var use_grid = $Background/M/V/TabContainer/Use/ScrollContainer/GridContainer
onready var equip_grid = $Background/M/V/TabContainer/Equip/ScrollContainer/GridContainer
onready var etc_grid = $Background/M/V/TabContainer/ETC/ScrollContainer/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var inventory_tabs = Global.player.inventory.keys()
	var inv_ref = Global.player.inventory
	
	# scroll through tabs (equip, use, etc) notmade yet
	for tab in inventory_tabs:
		# for item in each tab
		for item in inv_ref[tab]:
			var inv_slot_new = inventory_slot.instance()
			# there is an item in data
			if item["itemID"] != null:
				var item_name = GameData.ItemTable[str(item["itemID"])]["itemName"]
				#var icon_texture = load()
				
				# if stackable
				if item["amount"] != null:
					pass
					inv_slot_new.get_node("RichTextLabel").text = str(item["amount"])
				#inv_slot_new.get_node("Icon").set_texture(icon_texture)
			if tab == "Equpment":
				equip_grid.add_child(inv_slot_new, true)
			elif tab == "Use":
				use_grid.add_child(inv_slot_new, true)
			elif tab == "ETC":
				etc_grid.add_child(inv_slot_new, true)
