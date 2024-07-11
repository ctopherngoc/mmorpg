extends Node

var monsterTable: Dictionary
var itemTable: Dictionary
var equipmentTable: Dictionary
var string_validation: Array
var npcTable

# Called when the node enters the scene tree for the first time.
func _ready():
	var data_file = File.new()
	data_file.open("res://data/GameDataTable.json", File.READ)
	var gamedata_json = JSON.parse(data_file.get_as_text())
	
	monsterTable = gamedata_json.result["MonsterTable"]
	itemTable = gamedata_json.result["ItemTable"]
	equipmentTable = gamedata_json.result["EquipmentTable"]	
	npcTable = gamedata_json.result["NPCTable"]	
	data_file.close()
	
# warning-ignore:unused_variable
	var file = File.new()
	data_file.open("res://data/StringValidation.json", File.READ)
	var string_validation = JSON.parse(data_file.get_as_text()).result
	data_file.close()
	
onready var bgm_dict = {
	'menu': preload("res://resources/sounds/bgm/Dream Sakura_Loop.ogg"),
	'Remy': preload("res://resources/sounds/bgm/OurMusicBox - Beyond The Hills.mp3"),}
	
onready var menu_sound_dict = {
	'click': preload("res://resources/sounds/menu/button_click.mp3"),
	'hover': preload("res://resources/sounds/menu/button_hover.mp3"),
}

onready var region_dict = {
	'0001': "Remy",
}
onready var monster_preload = {
	"100001" : preload("res://scenes/monsterObjects/100001/100001.tscn"),
	"100002" : preload("res://scenes/monsterObjects/100002/100002.tscn"),
	"100003" : preload("res://scenes/monsterObjects/100003/100003.tscn"),
	"100004" : preload("res://scenes/monsterObjects/100004/100004.tscn"),
	"100005" : preload("res://scenes/monsterObjects/100005/100005.tscn"),
	"100006" : preload("res://scenes/monsterObjects/100006/100006.tscn"),
	"100007" : preload("res://scenes/monsterObjects/100007/100007.tscn"),
	"100008" : preload("res://scenes/monsterObjects/100008/100008.tscn"),
	"100009" : preload("res://scenes/monsterObjects/100009/100009.tscn"),
	"100010" : preload("res://scenes/monsterObjects/100010/100010.tscn"),
	
	
}
onready var map_dict = {
	"100000": {"name": "Grassy Road 1 Test", "path": "res://scenes/maps/100000/100000.tscn", "region": "Remy", "bgm": "Remy"},
	"100001": {"name": "Grassy Road 1", "path": "res://scenes/maps/100001/100001.tscn", "region": "Remy", "bgm": "Remy"},
	"100002": {"name": "Grassy Road 2", "path": "res://scenes/maps/100002/100002.tscn", "region": "Remy", "bgm": "Remy"},
	"100003": {"name": "Grassy Road 3", "path": "res://scenes/maps/100003/100003.tscn", "region": "Remy", "bgm": "Remy"},
}

onready var job_dict = {
	"0": "Beginner",
	"1": "Warrior",
	"2": "Mage",
	"3": "Archer",
	"4": "Thief",
}

# no rfinger
onready var avatar_sprite = {
	"body": "res://assets/character/spritesheet/body/",
	"brow" : "res://assets/character/spritesheet/brow/",
	"earc" : "res://assets/character/spritesheet/earc/",
	"eye" : "res://assets/character/spritesheet/eye/",
	"hair": "res://assets/character/spritesheet/hair/",
	"head" : "res://assets/character/spritesheet/head/",
	"larm" : "res://assets/character/spritesheet/larm/",
	"lear" : "res://assets/character/spritesheet/lear/",
	"lfinger" : "res://assets/character/spritesheet/lfinger/",
	"lhand" : "res://assets/character/spritesheet/lhand/",
	"lleg" : "res://assets/character/spritesheet/lleg/",
	"mouth" : "res://assets/character/spritesheet/mouth/",
	"rarm" : "res://assets/character/spritesheet/rarm/",
	"rear" : "res://assets/character/spritesheet/rear/",
	"rhand" : "res://assets/character/spritesheet/rhand/",
	"rleg" : "res://assets/character/spritesheet/rleg/",
	}
	
onready var climb_sprite = {
	"body": "res://assets/character/spritesheet/body/",
	"hair": "res://assets/character/spritesheet/hair/",
	"ear" : "res://assets/character/spritesheet/earc/",
	}
	
onready var equipment_sprite = {
	"headgear" : "res://assets/character/spritesheet/headgear/",
	"bottom" : "res://assets/character/spritesheet/bottom/",
	"default" : "res://assets/character/spritesheet/default/",
	"earring" : "res://assets/character/spritesheet/earring/",
	"eyeacc" : "res://assets/character/spritesheet/eyeacc/",
	"faceacc" : "res://assets/character/spritesheet/faceacc/",
	"glove" : "res://assets/character/spritesheet/glove/",
	"lweapon" : "res://assets/character/spritesheet/lweapon/",
	"rweapon" : "res://assets/character/spritesheet/rweapon/",
	"tattoo" : "res://assets/character/spritesheet/tattoo/",
	"top" : "res://assets/character/spritesheet/top/",
}

onready var test_player = {
	"displayname": "test",
	"map": "100000",
	"avatar" : {
			"head": "1",
			"hair": "1",
			"hcolor": "1",
			"body": "1",
			"bcolor": "1",
			"brow": "1",
			"ear": "1",
			"mouth": "1",
			"eye": "1",
			"ecolor": "1",
		},
	"equipment": {
		"rweapon": {
			"id": 200005,
			"uniqueID":14333321,
			"job": 0,
			"type": "1h_sword",
			"name": "temp sword",
			"speed": 5,
			"slot": 7,
			"attack": 15,
			"magic": 0,
			"maxHealth": 0,
			"maxMana": 0,
			"strength": 5,
			"wisdom": 5,
			"dexterity": 5,
			"luck": 5,
			"movementSpeed": 0,
			"jumpSpeed": 0,
			"avoidability": 0,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 0,
			"bossPercent": 0,
			"damagePercent": 0,
			"critRate": 0,},
		"lweapon": 200001,
		"faceacc": -1,
		"top": 500002,
		"bottom": 500003,
		"tattoo": -1,
		"glove": -1,
		"eyeacc": -1,
		"headgear": -1,
		"pocket": -1,
		"earring": -1,
		"ring1": -1,
		"ring2": -1,
		"ring3": -1,
		"ammo": 200004},#equip
	"stats": 
	{
		"base": {
			"maxRange": 50,
			"minRange": 0,
			"health": 50,
			"mana": 50,
			"maxHealth": 50,
			"maxMana": 50,
			"level": 1,
			"experience": 0,
			#"class": 0,
			"job": 0,
			"sp": 0,
			"ap": 0,
			"strength": 4,
			"wisdom": 4,
			"dexterity": 4,
			"luck": 4,
			"movementSpeed": 100,
			"jumpSpeed": 200,
			"avoidability": 4,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 10,
			"bossPercent": 1,
			"damagePercent": 1,
			"critRate": 5,
		},
		"equipment": {
			"attack": 0,
			"magic": 0,
			"maxHealth": 0,
			"maxMana": 0,
			"strength": 0,
			"wisdom": 0,
			"dexterity": 0,
			"luck": 0,
			"movementSpeed": 0,
			"jumpSpeed": 0,
			"avoidability": 0,
			"defense": 0,
			"magicDefense": 0,
			"accuracy": 0,
			"bossPercent": 0,
			"damagePercent": 0,
			"critRate": 0,
		},
	},
	"inventory" : {
			"100000": 0,
	},
}

onready var weapon_speed = {
	"1" : 1.4,
	"2" : 1.6,
	"3" : 1.8,
	"4" : 2.0,
	"5" : 2.2,
	"6" : 2.4,
}

onready var experience_table = {
	'1': 20,
	'2': 38,
	'3': 72,
	'4': 137,
	'5': 260,
	'6': 364,
	'7': 510,
	'8': 714,
	'9': 1000,
	'10': 1400,
	'11': 1820,
	'12': 2366,
	'13': 3076,
	'14': 3999,
	'15': 5199,
	'16': 6759,
	'17': 8787,
	'18': 11423,
	'19': 14850,
	'20': 17820,
	'21': 21384,
	'22': 25661,
	'23': 30793,
	'24': 36952,
	'25': 40647,
	'26': 44712,
	'27': 49183,
	'28': 54101,
	'29': 59511,
	'30': 65462,
}

onready var item_preload = {
	"100000": preload("res://scenes/itemObjects/100000.tscn"),
	"item": preload("res://scenes/itemObjects/item.tscn"),
}

onready var skill_data = {
	"0" : {
		"0": {"name": "Godot Ball", "id": "600000",  "maxLevel": 3, "targetCount": [1,1,1], "description": "Throw a projectile forward", "stat": {"damagePercent": [1.3, 1.5, 1.7]}, "mana": [25, 20, 15], "cooldown": [0, 0, 0], "type": "attack", "attackType": "projectile", "weaponType": null, "damageType": 1, "hitAmount": [2,3,4]},
		"1": {"name": "Tenacious Heal", "id": "600001",  "maxLevel": 3, "description": "Heals for a small amount", "stat": {"health": [25, 50, 100]}, "mana": [30,20,10], "cooldown": [180, 120, 60], "type": "heal", "healType": "self"},
		"2": {"name": "Swift Speed", "id": "600002", "maxLevel": 3, "description": "Incrase speed for a short time", "stat": {"movementSpeed": [10, 20, 30]}, "mana":[30,20,10], "duration": [30,30,30], "cooldown": [180, 120, 60], "type": "buff", "buffType": "self"},
		},
	"1" : {},
	"2" : {},
	"3" : {},
	"4" : {},
}

onready var skill_class_dictionary = {
	"600000" : {"class":[0,1,2,3,4], "location": ["0","0"], "icon": "res://assets/skillSprites/0/600000.png", "projectile_sprite": "res://assets/skillSprites/0/600000.png"},
	"600001" : {"class":[0,1,2,3,4], "location": ["0","1"], "icon": "res://assets/skillSprites/0/600001.png"},
	"600002" : {"class":[0,1,2,3,4], "location": ["0","2"], "icon": "res://assets/skillSprites/0/600002.png"},
}

onready var mandatory_keys = ["attack", "skill", "inventory", "stat", "loot", "equipment"]

onready var animation_dict: Dictionary = {
	"attack": "slash",
	"600000": "ready",
	"600001": "ready",
	"600002": "ready",
}

onready var full_headgear_list = ["500006"]
