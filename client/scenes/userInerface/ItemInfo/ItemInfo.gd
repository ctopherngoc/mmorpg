extends Popup

var origin: String
var slot: int
var stats: Dictionary
var valid: bool = false

onready var item_path= "res://assets/itemSprites/"
var itemStat = preload("res://scenes/userInerface/ItemInfo/ItemStatsLine.tscn")

onready var itemName = $N/MarginContainer/VBoxContainer/Label
onready var description = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label
onready var itemIcon = $N/MarginContainer/VBoxContainer/HBoxContainer/TextureRect

func _ready() -> void:
	var item_id
	if Global.player.inventory.equipment[slot] != null:
		stats = Global.player.inventory.equipment[slot].duplicate()
		valid = true
	
	if valid:
		itemName.text = stats.name
		description.text = GameData.itemTable[stats.id].description
		if GameData.itemTable[stats.id].itemType == "use":
			var temp_item_path = item_path + "useItems/" + str(stats.id) + ".png"
			itemIcon.texture = load(temp_item_path)
		elif GameData.itemTable[stats.id].itemType == "etc":
			var temp_item_path = item_path + "etcItems/" + str(stats.id) + ".png"
			itemIcon.texture = load(temp_item_path)
