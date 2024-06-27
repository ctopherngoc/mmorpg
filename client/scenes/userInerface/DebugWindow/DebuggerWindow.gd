extends Control

onready var label = $Label
func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	if Global.in_game:
		label.text = "movementSpeed: " + str(Global.player.stats.base.movementSpeed + Global.player.stats.equipment.movementSpeed + Global.player.stats.buff.movementSpeed)
		label.text += "\nStrength: " + str(Global.player.stats.base.strength + Global.player.stats.equipment.strength + Global.player.stats.buff.strength)
		label.text += "\nDexterity: " + str(Global.player.stats.base.dexterity + Global.player.stats.equipment.dexterity + Global.player.stats.buff.dexterity)
		label.text += "\nWisdom: " + str(Global.player.stats.base.wisdom + Global.player.stats.equipment.wisdom + Global.player.stats.buff.wisdom)
		label.text += "\nLuck: " + str(Global.player.stats.base.luck + Global.player.stats.equipment.luck + Global.player.stats.buff.luck)
		label.text += "\nmagicDefense: " + str(Global.player.stats.base.magicDefense + Global.player.stats.equipment.magicDefense + Global.player.stats.buff.magicDefense)
		label.text += "\nDefense: " + str(Global.player.stats.base.defense + Global.player.stats.equipment.defense + Global.player.stats.buff.defense)
