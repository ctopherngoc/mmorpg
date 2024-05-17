extends Popup

var origin: String
var tab: String
var slot: int
var stats: Dictionary
var valid: bool = false

var itemStat = preload("res://scenes/userInerface/ItemInfo/ItemStatsLine.tscn")

onready var extraStats = $N/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer
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
	if origin == "Inventory":
		if Global.player.inventory.equipment[slot] != null:
			stats = Global.player.inventory.equipment[slot]
			valid = true
			print("stats: %s" % stats)
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
		reqLevel.text = str(GameData.equipmentTable[stats.id].reqLevel)
		reqStr.text = str(GameData.equipmentTable[stats.id].reqStr)
		reqLuk.text = str(GameData.equipmentTable[stats.id].reqLuk)
		reqDex.text = str(GameData.equipmentTable[stats.id].reqDex)
		reqWis.text = str(GameData.equipmentTable[stats.id].reqWis)
		if stats.job == null:
			reqJob.text = "All"
		else:
			reqJob.text = stats.job
		
		##########################################################################
		# aditional equip stats 
		
		var type = itemStat.instance()
		type.get_node("StatLabel").text = "Type: "
		type.get_node("StatNumber").text =  str(stats.type)
		extraStats.add_child(type)
		
		if stats.type in ["1h_sword", "bow", "gun", "1h_blunt", "2h_blunt", "1h_axe", "2h_axe", "dagger", "wand", "staff"]:
			var speed = itemStat.instance()
			speed.get_node("StatLabel").text = "Weapon Speed: "
			speed.get_node("StatNumber").text =  str(stats.attackSpeed)
			extraStats.add_child(speed)
			
			var attack = itemStat.instance()
			attack.get_node("StatLabel").text = "Attack: "
			attack.get_node("StatNumber").text =  str(stats.attack)
			extraStats.add_child(attack)
			
			if stats.magic != "0":
				var magic = itemStat.instance()
				magic.get_node("StatLabel").text = "Magic: "
				magic.get_node("StatNumber").text = str(stats.magic)
				extraStats.add_child(magic)
		
		if stats.strength != "0":
				var strength = itemStat.instance()
				strength.get_node("StatLabel").text = "STR: "
				strength.get_node("StatNumber").text =  "+" + str(stats.strength)
				extraStats.add_child(strength)
		
		if stats.dexterity != "0":
				var dexterity = itemStat.instance()
				dexterity.get_node("StatLabel").text = "DEX: "
				dexterity.get_node("StatNumber").text =  "+" + str(stats.dexterity)
				extraStats.add_child(dexterity)
		
		if stats.wisdom != "0":
				var wisdom = itemStat.instance()
				wisdom.get_node("StatLabel").text = "WIS: "
				wisdom.get_node("StatNumber").text =  "+" + str(stats.wisdom)
				extraStats.add_child(wisdom)
		
		if stats.luck != "0":
				var luck = itemStat.instance()
				luck.get_node("StatLabel").text = "LUK: "
				luck.get_node("StatNumber").text =  "+" + str(stats.luck)
				extraStats.add_child(luck)
		
		if stats.critRate != "0":
				var critRate = itemStat.instance()
				critRate.get_node("StatLabel").text = "Crit Rate: "
				critRate.get_node("StatNumber").text =  "+" + str(stats.critRate) + "%"
				extraStats.add_child(critRate)
				
		if stats.bossPercent != "0":
				var bossPercent = itemStat.instance()
				bossPercent.get_node("StatLabel").text = "Boss Damage: "
				bossPercent.get_node("StatNumber").text =  "+" + str(stats.bossPercent) + "%"
				extraStats.add_child(bossPercent)
		
		if stats.damagePercent != "0":
				var damagePercent = itemStat.instance()
				damagePercent.get_node("StatLabel").text = "Total Damage: "
				damagePercent.get_node("StatNumber").text =  "+" + str(stats.damagePercent) + "%"
				extraStats.add_child(damagePercent)
				
		if stats.accuracy != "0":
				var accuracy = itemStat.instance()
				accuracy.get_node("StatLabel").text = "Total Damage: "
				accuracy.get_node("StatNumber").text =  "+" + str(stats.accuracy)
				extraStats.add_child(accuracy)
		
		if stats.maxHealth != "0":
				var maxHealth = itemStat.instance()
				maxHealth.get_node("StatLabel").text = "Health: "
				maxHealth.get_node("StatNumber").text =  "+" + str(stats.maxHealth)
				extraStats.add_child(maxHealth)
		
		if stats.maxMana != "0":
				var maxMana = itemStat.instance()
				maxMana.get_node("StatLabel").text = "Mana: "
				maxMana.get_node("StatNumber").text =  "+" + str(stats.maxMana)
				extraStats.add_child(maxMana)
				
		if stats.defense != "0":
				var defense = itemStat.instance()
				defense.get_node("StatLabel").text = "W.Defense: "
				defense.get_node("StatNumber").text =  "+" + str(stats.defense)
				extraStats.add_child(defense)
		
		if stats.magicDefense != "0":
				var magicDefense = itemStat.instance()
				magicDefense.get_node("StatLabel").text = "M.Defense: "
				magicDefense.get_node("StatNumber").text =  "+" + str(stats.magicDefense)
				extraStats.add_child(magicDefense)
		
		if stats.avoidability != "0":
				var avoidability = itemStat.instance()
				avoidability.get_node("StatLabel").text = "Avoid: "
				avoidability.get_node("StatNumber").text =  "+" + str(stats.avoidability)
				extraStats.add_child(avoidability)
		
		if stats.movementSpeed != "0":
				var movementSpeed = itemStat.instance()
				movementSpeed.get_node("StatLabel").text = "Speed: "
				movementSpeed.get_node("StatNumber").text =  "+" + str(stats.movementSpeed)
				extraStats.add_child(movementSpeed)
				
		if stats.jumpSpeed != "0":
				var jumpSpeed = itemStat.instance()
				jumpSpeed.get_node("StatLabel").text = "Jump: "
				jumpSpeed.get_node("StatNumber").text =  "+" + str(stats.jumpSpeed)
				extraStats.add_child(jumpSpeed)
				
		if stats.slot != null:
			var scroll_slot = itemStat.instance()
			scroll_slot.get_node("StatLabel").text = "Slots: "
			scroll_slot.get_node("StatNumber").text = str(stats.slot)
			extraStats.add_child(scroll_slot)
			
		##########################################################################
