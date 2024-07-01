extends Popup

var origin: String
var tab: String
var slot: int
var stats: Dictionary
var valid: bool = false

var itemStat = preload("res://scenes/userInerface/ItemInfo/ItemStatsLine.tscn")

onready var extraStats = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer
onready var itemName = $Background/MarginContainer/VBoxContainer/Label
onready var reqLevel = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LevelJob/Level/Label2
onready var reqJob = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LevelJob/Job/Label2
onready var reqStr = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/STRLUK/Str/Label2
onready var reqLuk = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/STRLUK/Luk/Label2
onready var reqDex = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/DEXWIS/Dex/Label2
onready var reqWis = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ReqStats/DEXWIS/Wis/Label2
onready var itemIcon = $Background/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
onready var item_path = "res://assets/itemSprites/"

func _ready() -> void:
	if origin == "Inventory":
		if Global.player.inventory.equipment[slot] != null:
			stats = Global.player.inventory.equipment[slot]
			valid = true
			#print("stats: %s" % stats)
	if origin == "Equipment":
		print(tab)
		if Global.player.equipment[tab] != null:
			stats = Global.player.equipment[tab]
			valid = true
	
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
			reqJob.text = GameData.job_dict[str(stats.job)]
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
			if stats.attack > GameData.equipmentTable[stats.id].attack:
				attack.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
				attack.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
			elif stats.attack < GameData.equipmentTable[stats.id].attack:
				attack.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
				attack.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
			extraStats.add_child(attack)
			
			if stats.magic != 0:
				var magic = itemStat.instance()
				magic.get_node("StatLabel").text = "Magic: "
				magic.get_node("StatNumber").text = str(stats.magic)
				if stats.magic > GameData.equipmentTable[stats.id].magic:
					magic.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					magic.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.magic < GameData.equipmentTable[stats.id].magic:
					magic.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					magic.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(magic)
		
		if stats.strength != 0:
				var strength = itemStat.instance()
				strength.get_node("StatLabel").text = "STR: "
				strength.get_node("StatNumber").text =  "+" + str(stats.strength)
				print(stats.strength)
				print(GameData.equipmentTable[stats.id].strength)
				if stats.strength > GameData.equipmentTable[stats.id].strength:
					strength.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					strength.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.strength < GameData.equipmentTable[stats.id].strength:
					strength.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					strength.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(strength)
		
		if stats.dexterity != 0:
				var dexterity = itemStat.instance()
				dexterity.get_node("StatLabel").text = "DEX: "
				dexterity.get_node("StatNumber").text =  "+" + str(stats.dexterity)
				if stats.dexterity > GameData.equipmentTable[stats.id].dexterity:
					dexterity.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					dexterity.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.dexterity < GameData.equipmentTable[stats.id].dexterity:
					dexterity.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					dexterity.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(dexterity)
		
		if stats.wisdom != 0:
				var wisdom = itemStat.instance()
				wisdom.get_node("StatLabel").text = "WIS: "
				wisdom.get_node("StatNumber").text =  "+" + str(stats.wisdom)
				if stats.wisdom > GameData.equipmentTable[stats.id].wisdom:
					wisdom.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					wisdom.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.wisdom < GameData.equipmentTable[stats.id].wisdom:
					wisdom.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					wisdom.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(wisdom)
		
		if stats.luck != 0:
				var luck = itemStat.instance()
				luck.get_node("StatLabel").text = "LUK: "
				luck.get_node("StatNumber").text =  "+" + str(stats.luck)
				if stats.luck > GameData.equipmentTable[stats.id].luck:
					luck.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					luck.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.luck < GameData.equipmentTable[stats.id].luck:
					luck.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					luck.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(luck)
		
		if stats.critRate != 0:
				var critRate = itemStat.instance()
				critRate.get_node("StatLabel").text = "Crit Rate: "
				critRate.get_node("StatNumber").text =  "+" + str(stats.critRate) + "%"
				if stats.critRate > GameData.equipmentTable[stats.id].critRate:
					critRate.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					critRate.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.critRate < GameData.equipmentTable[stats.id].critRate:
					critRate.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					critRate.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(critRate)
				
		if stats.bossPercent != 0:
				var bossPercent = itemStat.instance()
				bossPercent.get_node("StatLabel").text = "Boss Damage: "
				bossPercent.get_node("StatNumber").text =  "+" + str(stats.bossPercent) + "%"
				if stats.bossPercent > GameData.equipmentTable[stats.id].bossPercent:
					bossPercent.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					bossPercent.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.bossPercent < GameData.equipmentTable[stats.id].bossPercent:
					bossPercent.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					bossPercent.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(bossPercent)
		
		if stats.damagePercent != 0:
				var damagePercent = itemStat.instance()
				damagePercent.get_node("StatLabel").text = "Total Damage: "
				damagePercent.get_node("StatNumber").text =  "+" + str(stats.damagePercent) + "%"
				if stats.damagePercent > GameData.equipmentTable[stats.id].damagePercent:
					damagePercent.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					damagePercent.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.damagePercent < GameData.equipmentTable[stats.id].damagePercent:
					damagePercent.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					damagePercent.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(damagePercent)
				
		if stats.accuracy != 0:
				var accuracy = itemStat.instance()
				accuracy.get_node("StatLabel").text = "Total Damage: "
				accuracy.get_node("StatNumber").text =  "+" + str(stats.accuracy)
				if stats.accuracy > GameData.equipmentTable[stats.id].accuracy:
					accuracy.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					accuracy.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.accuracy < GameData.equipmentTable[stats.id].accuracy:
					accuracy.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					accuracy.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(accuracy)
		
		if stats.maxHealth != 0:
				var maxHealth = itemStat.instance()
				maxHealth.get_node("StatLabel").text = "Health: "
				maxHealth.get_node("StatNumber").text =  "+" + str(stats.maxHealth)
				if stats.maxHealth > GameData.equipmentTable[stats.id].maxHealth:
					maxHealth.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					maxHealth.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.maxHealth < GameData.equipmentTable[stats.id].maxHealth:
					maxHealth.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					maxHealth.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(maxHealth)
		
		if stats.maxMana != 0:
				var maxMana = itemStat.instance()
				maxMana.get_node("StatLabel").text = "Mana: "
				maxMana.get_node("StatNumber").text =  "+" + str(stats.maxMana)
				if stats.maxMana > GameData.equipmentTable[stats.id].maxMana:
					maxMana.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					maxMana.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.maxMana < GameData.equipmentTable[stats.id].maxMana:
					maxMana.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					maxMana.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(maxMana)
				
		if stats.defense != 0:
				var defense = itemStat.instance()
				defense.get_node("StatLabel").text = "W.Defense: "
				defense.get_node("StatNumber").text =  "+" + str(stats.defense)
				if stats.defense > GameData.equipmentTable[stats.id].defense:
					defense.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					defense.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.defense < GameData.equipmentTable[stats.id].defense:
					defense.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					defense.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(defense)
		
		if stats.magicDefense != 0:
				var magicDefense = itemStat.instance()
				magicDefense.get_node("StatLabel").text = "M.Defense: "
				magicDefense.get_node("StatNumber").text =  "+" + str(stats.magicDefense)
				if stats.magicDefense > GameData.equipmentTable[stats.id].magicDefense:
					magicDefense.get_node("StatLabel").set("custom_colors/font_color", Color("00ff15"))
					magicDefense.get_node("StatNumber").set("custom_colors/font_color", Color("00ff15"))
				elif stats.magicDefense < GameData.equipmentTable[stats.id].magicDefense:
					magicDefense.get_node("StatLabel").set("custom_colors/font_color", Color("db0000"))
					magicDefense.get_node("StatNumber").set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(magicDefense)
		
		if stats.avoidability != 0:
				var avoidability = itemStat.instance()
				avoidability.get_node("StatLabel").text = "Avoid: "
				avoidability.get_node("StatNumber").text =  "+" + str(stats.avoidability)
				if stats.avoidability > GameData.equipmentTable[stats.id].avoidability:
					avoidability.get_node("StatLabel").text.set("custom_colors/font_color", Color("00ff15"))
					avoidability.get_node("StatNumber").text.set("custom_colors/font_color", Color("00ff15"))
				elif stats.avoidability < GameData.equipmentTable[stats.id].avoidability:
					avoidability.get_node("StatLabel").text.set("custom_colors/font_color", Color("db0000"))
					avoidability.get_node("StatNumber").text.set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(avoidability)
		
		if stats.movementSpeed != 0:
				var movementSpeed = itemStat.instance()
				movementSpeed.get_node("StatLabel").text = "Speed: "
				movementSpeed.get_node("StatNumber").text =  "+" + str(stats.movementSpeed)
				if stats.movementSpeed > GameData.equipmentTable[stats.id].movementSpeed:
					movementSpeed.get_node("StatLabel").text.set("custom_colors/font_color", Color("00ff15"))
					movementSpeed.get_node("StatNumber").text.set("custom_colors/font_color", Color("00ff15"))
				elif stats.movementSpeed < GameData.equipmentTable[stats.id].movementSpeed:
					movementSpeed.get_node("StatLabel").text.set("custom_colors/font_color", Color("db0000"))
					movementSpeed.get_node("StatNumber").text.set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(movementSpeed)
				
		if stats.jumpSpeed != 0:
				var jumpSpeed = itemStat.instance()
				jumpSpeed.get_node("StatLabel").text = "Jump: "
				jumpSpeed.get_node("StatNumber").text =  "+" + str(stats.jumpSpeed)
				if stats.jumpSpeed > GameData.equipmentTable[stats.id].jumpSpeed:
					jumpSpeed.get_node("StatLabel").text.set("custom_colors/font_color", Color("00ff15"))
					jumpSpeed.get_node("StatNumber").text.set("custom_colors/font_color", Color("00ff15"))
				elif stats.jumpSpeed < GameData.equipmentTable[stats.id].jumpSpeed:
					jumpSpeed.get_node("StatLabel").text.set("custom_colors/font_color", Color("db0000"))
					jumpSpeed.get_node("StatNumber").text.set("custom_colors/font_color", Color("db0000"))
				extraStats.add_child(jumpSpeed)
				
		if stats.slot != null:
			var scroll_slot = itemStat.instance()
			scroll_slot.get_node("StatLabel").text = "Slots: "
			scroll_slot.get_node("StatNumber").text = str(stats.slot)
			extraStats.add_child(scroll_slot)
			
		##########################################################################
