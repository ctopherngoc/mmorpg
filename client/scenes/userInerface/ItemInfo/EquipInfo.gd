extends Popup

var origin: String
var slot: int
var stats: Dictionary
var valid: bool = false

var itemStat = preload("res://scenes/userInerface/ItemInfo/ItemStatsLine.tscn")

onready var extraStats = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats
onready var itemName = $N/MarginContainer/VBoxContainer/Label
onready var reqLevel = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LevelJob/Level/Label2
onready var reqJob = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LevelJob/Job/Label2
onready var reqStr = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/STRLUK/Str/Label2
onready var reqLuk = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/STRLUK/Luk/Label2
onready var reqDex = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/DEXWIS/Dex/Label2
onready var reqWis = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/DEXWIS/Wis/Label2
onready var itemIcon = $N/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
onready var item_path = "res://assets/itemSprites/"

func _ready() -> void:
	var item_id
	if origin == "Inventory":
		if Global.player.inventory.equipment[slot] != null:
			stats = Global.player.inventory.equipment[slot]
			valid = true
	else:
		# if hovering equiped item 
		# if Global.player.equipment[slot] != null:
		pass
	
	if valid:
		# equip name
		itemName.text = stats.name
		
		# texture
		var temp_item_path = item_path + "equipItems/" + str(stats.id) + ".png"
		itemIcon.texture = load(temp_item_path)
		
		# required stats
		reqLevel.text = str(GameData.itemTable[stats.id].reqLevel)
		reqStr.text = str(GameData.itemTable[stats.id].reqStr)
		reqLuk.text = str(GameData.itemTable[stats.id].reqLuk)
		reqDex.text = str(GameData.itemTable[stats.id].reqDex)
		reqWis.text = str(GameData.itemTable[stats.id].reqWis)
		if stats.job == null:
			reqJob.text = "All"
		else:
			reqJob.text = stats.job
		
		##########################################################################
		# aditional equip stats 
		
		var type = itemStat.instance()
		type.label = "Type:"
		type.amount =  str(stats.type)
		extraStats.add_child(type)
		
		if stats.type in ["1h_sword", "bow", "gun", "1h_blunt", "2h_blunt", "1h_axe", "2h_axe", "dagger", "wand", "staff"]:
			var speed = itemStat.instance()
			speed.label = "Weapon Speed: "
			speed.amount =  str(stats.attackSpeed)
			extraStats.add_child(type)
			
			var attack = itemStat.instance()
			attack.label = "Attack: "
			attack.amount =  str(stats.attack)
			extraStats.add_child(type)
			
			if stats.magic != null:
				var magic = itemStat.instance()
				magic.label = "Magic: "
				magic.amount =  str(stats.magic)
				extraStats.add_child(type)
		
		if stats.strength != null:
				var strength = itemStat.instance()
				strength.label = "STR: "
				strength.amount =  "+ " + str(stats.strength)
				extraStats.add_child(type)
		
		if stats.dexterity != null:
				var dexterity = itemStat.instance()
				dexterity.label = "DEX: "
				dexterity.amount =  "+ " + str(stats.dexterity)
				extraStats.add_child(type)
		
		if stats.wisdom != null:
				var wisdom = itemStat.instance()
				wisdom.label = "WIS: "
				wisdom.amount =  "+ " + str(stats.wisdom)
				extraStats.add_child(type)
		
		if stats.luck != null:
				var luck = itemStat.instance()
				luck.label = "LUK: "
				luck.amount =  "+ " + str(stats.luck)
				extraStats.add_child(type)
		
		if stats.critRate != null:
				var critRate = itemStat.instance()
				critRate.label = "Crit Rate: "
				critRate.amount =  "+ " + str(stats.critRate) + "%"
				extraStats.add_child(type)
				
		if stats.bossPercent != null:
				var bossPercent = itemStat.instance()
				bossPercent.label = "Boss Damage: "
				bossPercent.amount =  "+ " + str(stats.bossPercent) + "%"
				extraStats.add_child(type)
		
		if stats.damagePercent != null:
				var damagePercent = itemStat.instance()
				damagePercent.label = "Total Damage: "
				damagePercent.amount =  "+ " + str(stats.damagePercent) + "%"
				extraStats.add_child(type)
				
		if stats.accuracy != null:
				var accuracy = itemStat.instance()
				accuracy.label = "Total Damage: "
				accuracy.amount =  "+ " + str(stats.accuracy)
				extraStats.add_child(type)
		
		if stats.maxHealth != null:
				var maxHealth = itemStat.instance()
				maxHealth.label = "Health: "
				maxHealth.amount =  "+ " + str(stats.maxHealth)
				extraStats.add_child(type)
		
		if stats.maxMana != null:
				var maxMana = itemStat.instance()
				maxMana.label = "Mana: "
				maxMana.amount =  "+ " + str(stats.maxMana)
				extraStats.add_child(type)
				
		if stats.defense != null:
				var defense = itemStat.instance()
				defense.label = "W.Defense: "
				defense.amount =  "+ " + str(stats.defense)
				extraStats.add_child(type)
		
		if stats.magicDefense != null:
				var magicDefense = itemStat.instance()
				magicDefense.label = "M.Defense: "
				magicDefense.amount =  "+ " + str(stats.magicDefense)
				extraStats.add_child(type)
		
		if stats.avoidability != null:
				var avoidability = itemStat.instance()
				avoidability.label = "Avoid: "
				avoidability.amount =  "+ " + str(stats.avoidability)
				extraStats.add_child(type)
		
		if stats.movementSpeed != null:
				var movementSpeed = itemStat.instance()
				movementSpeed.label = "Speed: "
				movementSpeed.amount =  "+ " + str(stats.movementSpeed)
				extraStats.add_child(type)
				
		if stats.jumpSpeed != null:
				var jumpSpeed = itemStat.instance()
				jumpSpeed.label = "Jump: "
				jumpSpeed.amount =  "+ " + str(stats.jumpSpeed)
				extraStats.add_child(type)
				
		if stats.slot != null:
			var slot = itemStat.instance()
			slot.label = "Slots: "
			slot.amount =  "+ " + str(stats.slot)
			extraStats.add_child(type)
			
		##########################################################################
