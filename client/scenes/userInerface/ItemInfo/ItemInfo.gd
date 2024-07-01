extends Popup

var origin: String
var tab : String
var slot: int
var stats: Dictionary
var valid: bool = false

var itemStat = preload("res://scenes/userInerface/ItemInfo/ItemStatsLine.tscn")

onready var itemName = $Background/MarginContainer/VBoxContainer/Label
onready var description = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label
onready var itemIcon = $Background/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
onready var item_path = "res://assets/itemSprites/"

func _ready() -> void:
	if origin == "Inventory":
		if Global.player.inventory[tab][slot] != null:
			stats = Global.player.inventory[tab][slot]
			valid = true
			#print("stats: %s" % stats)
	else:
		# if hovering equiped item 
		# if Global.player.equipment[slot] != null:
		pass
	
	if valid:
		# equip name
		itemName.text = GameData.itemTable[stats.id].itemName
		
		# texture
		if tab == "use":
			var temp_item_path = item_path + "useItems/" + str(stats.id) + ".png"
			itemIcon.texture = load(temp_item_path)
		elif tab == "etc":
			var temp_item_path = item_path + "etcItems/" + str(stats.id) + ".png"
			itemIcon.texture = load(temp_item_path)
		# required stats
		description.text = str(GameData.itemTable[stats.id].description)
