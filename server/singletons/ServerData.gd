extends Node

var player_location = {}
var username_list = {}
var player_state_collection = {}
var user_characters = {}
var characters_data = {}

var monsterTable
var itemTable
var equipmentTable

var chat_logs = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var data_file = File.new()
	data_file.open("res://data/GameDataTable.json", File.READ)
	var gamedata_json = JSON.parse(data_file.get_as_text())
	data_file.close()
	
	monsterTable = gamedata_json.result["MonsterTable"]
	itemTable = gamedata_json.result["ItemTable"]
	equipmentTable = gamedata_json.result["EquipmentTable"]
	
	#print(monsterTable)
	#print(equipmentTable)
	
	
#	var skill_data_file = File.new()
#	skill_data_file.open("res://Data/SkillData - Sheet1.json", File.READ)
#	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
#	skill_data_file.close()
#	skill_data = skill_data_json.result

onready var skill_data = {
	0 : {
		0: {"name": "Godot Ball", "id": "600000",  "maxLevel": 3, "description": "Throw a projectile forward", stat = [1.3, 1.5, 1.7], mana = [25, 20, 15], "cooldown": [0, 0, 0]},
		1: {"name": "Tenacious Heal", "id": "600001",  "maxLevel": 3, "description": "Heals for a small amount", stat = [25, 50, 100], mana = [30,20,10], "cooldown": [180, 120, 60]},
		2: {"name": "Swift Speed", "id": "600002", "maxLevel": 3, "description": "Incrase speed for a short time", stat = [1.1, 1.2, 1.3], mana = [30,20,10], "cooldown": [180, 120, 60]},
		},
	1 : {},
	2 : {},
	3 : {},
	4 : {},
}

onready var skill_class_dictionary = {
	"600000" : {"class":[0,1,2,3,4], "location": ["0","0"]},
	"600001" : {"class":[0,1,2,3,4], "location": ["0","1"]},
	"600002" : {"class":[0,1,2,3,4], "location": ["0","2"]},
}

var monsters = {
	"100001" : {},
	"100002" : {},
	"100003" : {},
	"100004" : {},
}

var items = {
	"100001" : {},
	"100002" : {},
	"100003" : {},
	"100004" : {},
}

# current emails logged in
var logged_emails = []
var player_id_emails = {}

#firebase used to create new chracters
var static_data = {
	"job_skills" : 
		{
		0: [],
		1: [],
		2: [],
		3: [],
		4: [],
		5: [],
	},
	"player_info" : {
		"displayname": {'stringValue': null},
		"map": {'integerValue': null},
		"stats" : { "mapValue":
			{"fields": 
				{"base":
					{"mapValue": 
						{"fields":
							{"maxRange": {'integerValue': null},
							"minRange": {'integerValue': null},
							"maxHealth": {'integerValue': null},
							"health": {'integerValue': null},
							"maxMana": {'integerValue': null},
							"mana": {'integerValue': null},
							"level": {'integerValue': null},
							"experience": {'integerValue': null},
							#"class": {'integerValue': null},
							"job": {'integerValue': null},
							"sp": {'integerValue': null},
							"ap": {'integerValue': null},
							"strength": {'integerValue': null},
							"wisdom": {'integerValue': null},
							"dexterity": {'integerValue': null},
							"luck": {'integerValue': null},
							"movementSpeed": {'integerValue': null},
							"jumpSpeed": {'integerValue': null},
							"avoidability": {'integerValue': null},
							"defense": {'integerValue': null},
							"magicDefense": {'integerValue': null},
							"accuracy": {'integerValue': null},
							"bossPercent": {'integerValue': null},
							"damagePercent": {'integerValue': null},
							"critRate": {'integerValue': null},
						}, #fields
					}, #mapvalue
				}, #base
				"equipment":
					{"mapValue":
						{"fields":
							{"attack": {'integerValue': null},
							"magic": {'integerValue': null},
							"maxHealth": {'integerValue': null},
							"maxMana": {'integerValue': null},
							"strength": {'integerValue': null},
							"wisdom": {'integerValue': null},
							"dexterity": {'integerValue': null},
							"luck": {'integerValue': null},
							"movementSpeed": {'integerValue': null},
							"jumpSpeed": {'integerValue': null},
							"avoidability": {'integerValue': null},
							"defense": {'integerValue': null},
							"magicDefense": {'integerValue': null},
							"accuracy": {'integerValue': null},
							"bossPercent": {'integerValue': null},
							"damagePercent": {'integerValue': null},
							"critRate": {'integerValue': null},
						}, #fields
					}, # mapvalue
				}, #equipment
			}, #fields
			}, #mapvalue
		}, #stats
		"avatar" : { "mapValue":
			{"fields" :{
				"head": {'stringValue': null},
				"hair": {'stringValue': null},
				"hcolor": {'stringValue': null},
				"body": {'stringValue': null},
				"bcolor": {'stringValue': null},
				"ear": {'stringValue': null},
				"mouth": {'stringValue': null},
				"eye": {'stringValue': null},
				"ecolor": {'stringValue': null},
				"brow": {'stringValue': null},
			} #fields
			} #mapvalue
		}, # avatar
		"equipment" : {"mapValue":
			{"fields": 
				{"ammo": {'integerValue': null},
				"headgear": {'integerValue': null},
				"faceacc": {'integerValue': null},
				"eyeacc": {'integerValue': null},
				"top": {'integerValue': null},
				"bottom": {'integerValue': null},
				"earring": {'integerValue': null},
				"glove": {'integerValue': null},
				"pocket": {'integerValue': null},
				"lweapon": {'integerValue': null},
				"rweapon": {'integerValue': null},
				"tattoo": {'integerValue': null},
				}#fields
			}#mapvalue
		}, #equipment
		"skills" : {"mapValue" :
			{"fields" : { "0" : {"mapValue":
							{"fields":
								{"0": {"integerValue" : null},
								"1": {"integerValue": null},
								"2": {"integerValue": null},
								} # beginner class skillls
					} # classes fields
				} # mapvalue
			} # fields
		} # skills-mapvalue
		}, # skills
		"inventory" : {"mapValue":
			{"fields": 
				{"100000": {'integerValue': null},
				"equipment": {'arrayValue':{'values':[{"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}]}},
				"use": {'arrayValue':{'values':[{"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null},]}},
				"etc": {'arrayValue':{'values':[{"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null}, {"nullValue": null},]}},
				}#fields
			}#mapvalue
		}, #inventory
		"keybind": {'mapValue': 
			{"fields":
				{'shift': {"nullValue": null}, 'ins': {"nullValue": null}, 'home': {"nullValue": null}, 'pgup': {"nullValue": null}, 'ctrl': {"stringValue": "attack"},  'del': {"nullValue": null}, 'end': {"nullValue": null}, 'pgdn': {"nullValue": null},
				'`': {"nullValue": null}, '1': {"nullValue": null}, '2': {"nullValue": null}, '3': {"nullValue": null}, '4': {"nullValue": null}, '5': {"nullValue": null}, '6': {"nullValue": null}, '7': {"nullValue": null}, '8': {"nullValue": null}, '9': {"nullValue": null}, '0': {"nullValue": null}, '-': {"nullValue": null}, '=': {"nullValue": null},
				 'f1': {"nullValue": null}, 'f2': {"nullValue": null}, 'f3': {"nullValue": null}, 'f4': {"nullValue": null}, 'f5': {"nullValue": null}, 'f6': {"nullValue": null}, 'f7': {"nullValue": null}, 'f8': {"nullValue": null}, 'f9': {"nullValue": null}, 'f10': {"nullValue": null}, 'f11': {"nullValue": null}, 'f12': {"nullValue": null},
				'q': {"nullValue": null}, 'w': {"nullValue": null}, 'e': {"nullValue": null}, 'r': {"nullValue": null}, 't': {"nullValue": null}, 'y': {"nullValue": null}, 'u': {"nullValue": null}, 'i': {"stringValue": 'inventory'}, 'o': {"nullValue": null}, 'p': {"nullValue": null}, '[': {"nullValue": null}, ']': {"nullValue": null},
				'a': {"nullValue": null}, 's': {"stringValue": "stat"}, 'd': {"nullValue": null}, 'f': {"nullValue": null}, 'g': {"nullValue": null}, 'h': {"nullValue": null}, 'j': {"nullValue": null}, 'k': {"stringValue": 'skill'}, 'l': {"nullValue": null}, ';': {"nullValue": null}, "'": {"nullValue": null},
				'z': {"stringValue": 'loot'}, 'x': {"nullValue": null}, 'c': {"nullValue": null}, 'v': {"nullValue": null}, 'b': {"nullValue": null}, 'n': {"nullValue": null}, 'm': {"nullValue": null}, ',': {"nullValue": null}, '.': {"nullValue": null}, '/': {"nullValue": null},
				},
			},
		},
	},
	"player_template" : {
		"displayname": null,
		"map": "100001",
		"stats" : {
			"base": {
				"maxRange": 0,
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
				"maxHealth": 0,
				"magic": 0,
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
				"attack": 0,
		},
		}, #stats
		"skills": {
			"0" : {"0": 0,
					"1": 0,
					"2": 0,
				},
		}, # skills
		"avatar" : {
			"head": null,
			"hair": null,
			"hcolor": null,
			"body": null,
			"bcolor": null,
			"brow": null,
			"ear": null,
			"mouth": null,
			"eye": null,
			"ecolor": null,
		},
		"equipment" : {
				"ammo": -1,
				"headgear": -1,
				"faceacc": -1,
				"eyeacc": -1,
				"earring":-1,
				"top": null,
				"bottom": null,
				"glove": -1,
				"lweapon": -1,
				"rweapon": -1,
				#"rweapon": {"accuracy":0, "attack":15, "avoidability":0, "bossPercent":0, "critRate":0, "damagePercent":0, "defense":0, "dexterity":4, "id":"200001", "job":0, "jumpSpeed":0, "luck":5, "magic":0, "magicDefense":0, "maxHealth":0, "maxMana":0, "movementSpeed":0, "name":"Training Sword", "slot":7, "speed":5, "strength":5, "type":"1h_sword", "uniqueID":1000000, "wisdom":5},
				"pocket": -1,
				"tattoo": -1,
				}, #equipment
		 "inventory":{"100000":0,
			"equipment": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null],
			"etc": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null],
			"use": [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]
			}, #inventory
		"keybind": {
			'shift': null, 'ins': null, 'home': null, 'pgup': null, 'ctrl': null,  'del': null, 'end': null, 'pgdn': null,
			'`': null, '1': null, '2': null, '3': null, '4': null, '5': null, '6': null, '7': null, '8': null, '9': null, '0': null, '-': null, '=': null,
			'f1': null, 'f2': null, 'f3': null, 'f4': null, 'f5': null, 'f6': null, 'f7': null, 'f8': null, 'f9': null, 'f10': null, 'f11': null, 'f12': null,
			'q': null, 'w': null, 'e': null, 'r': null, 't': null, 'y': null, 'u': null, 'i': null, 'o': null, 'p': null, '[': null, ']': null,
			'a': null, 's': null, 'd': null, 'f': null, 'g': null, 'h': null, 'j': null, 'k': null, 'l': null, ';': null, "'": null,
			'z': null, 'x': null, 'c': null, 'v': null, 'b': null, 'n': null, 'm': null, ',': null, '.': null, '/': null,
			}, # keybind
		}, #player_template
	"starter_equips" : 
		[
			[500000, 500001],
			[500002, 500003],
			[500004, 500005],
		],
	"equipment_data_template" : {
		"id": "",
		"job": 0,
		"uniqueID":"",
		"type": "",
		"name": "",
		"slot": 7,
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
	"equipment_stats_template" : {
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
	"weapon_ratio" : {
		"1h_sword": 1.2,
		"2h_sword": 1.5,
		"staff": 0.8,},
	"weapon_speed" : {
		1 : null,
		2 : null,
		3 : null,
		4 : 2.0,
		5 : 2.2,
		6 : null,
		},
	"job_dict" : {
		0: {"job": "Beginner", "Weapon": [], "Range": 0, "HealthMin": 15, "HealthMax": 20},
		1: {"job": "Warrior", "Weapon": ["sword", "hammer", "axe"], "Range": 0, "HealthMin":30, "HealthMax": 35},
		2: {"job": "Rouge", "Weapon" : ["dagger"], "Range": 0, "HealthMin":20, "HealthMax": 25},
		3: {"job": "Archer", "Weapon" : ["bow"], "Range": 1, "HealthMin":15, "HealthMax": 20},
		4: {"job": "Magician", "Weapon" : [], "Range": 0, "HealthMin":15, "HealthMax": 20},
		5: {"job": "Gunner", "Weapon" : ["gun"], "Range": 1, "HealthMin":15, "HealthMax": 20},
		},
	"experience_table" : {
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
	},
	"fb_equipment_template" : {
		"owner": {"stringValue": ""},
		"id": {"stringValue": ""},
		"job": {"integerValue": 0},
		"uniqueID":{"stringValue": ""},
		"type": {"stringValue": ""},
		"name": {"stringValue": ""},
		"slot": {"integerValue": 0},
		"attack": {"integerValue": 0},
		"magic": {"integerValue": 0},
		"maxHealth": {"integerValue": 0},
		"maxMana":{"integerValue": 0},
		"strength": {"integerValue": 0},
		"wisdom": {"integerValue": 0},
		"dexterity": {"integerValue": 0},
		"luck": {"integerValue": 0},
		"movementSpeed": {"integerValue": 0},
		"jumpSpeed": {"integerValue": 0},
		"avoidability": {"integerValue": 0},
		"defense": {"integerValue": 0},
		"magicDefense": {"integerValue": 0},
		"accuracy": {"integerValue": 0},
		"bossPercent": {"integerValue": 0},
		"damagePercent": {"integerValue": 0},
		"critRate": {"integerValue": 0},
		"attackSpeed": {"integerValue": 0},
		},
	"server_keybind_template": {
	'shift': null, 'ins': null, 'home': null, 'pgup': null, 'ctrl': null,  'del': null, 'end': null, 'pgdn': null,
	'`': null, '1': null, '2': null, '3': null, '4': null, '5': null, '6': null, '7': null, '8': null, '9': null, '0': null, '-': null, '=': null,
	 'f1': null, 'f2': null, 'f3': null, 'f4': null, 'f5': null, 'f6': null, 'f7': null, 'f8': null, 'f9': null, 'f10': null, 'f11': null, 'f12': null,
	'q': null, 'w': null, 'e': null, 'r': null, 't': null, 'y': null, 'u': null, 'i': null, 'o': null, 'p': null, '[': null, ']': null,
	'a': null, 's': null, 'd': null, 'f': null, 'g': null, 'h': null, 'j': null, 'k': null, 'l': null, ';': null, "'": null,
	'z': null, 'x': null, 'c': null, 'v': null, 'b': null, 'n': null, 'm': null, ',': null, '.': null, '/': null,
	},
	"default_keybind": {
	'shift': null, 'ins': null, 'home': null, 'pgup': null, 'ctrl': "attack",  'del': null, 'end': null, 'pgdn': null,
	'`': null, '1': null, '2': null, '3': null, '4': null, '5': null, '6': null, '7': null, '8': null, '9': null, '0': null, '-': null, '=': null,
	 'f1': null, 'f2': null, 'f3': null, 'f4': null, 'f5': null, 'f6': null, 'f7': null, 'f8': null, 'f9': null, 'f10': null, 'f11': null, 'f12': null,
	'q': null, 'w': null, 'e': null, 'r': null, 't': null, 'y': null, 'u': null, 'i': 'inventory', 'o': null, 'p': null, '[': null, ']': null,
	'a': null, 's': "stat", 'd': null, 'f': null, 'g': null, 'h': null, 'j': null, 'k': 'skill', 'l': null, ';': null, "'": null,
	'z': 'loot', 'x': null, 'c': null, 'v': null, 'b': null, 'n': null, 'm': null, ',': null, '.': null, '/': null,
	},
}

var portal_data = {
	"100001": {
		'P1': {'map': '100002',
					'spawn': Vector2(110, -275)},
	},
	'100002': {
		'P1': {'map': '100001',
					'spawn': Vector2(837, -108)},
		'P2': {'map': '100003',
					'spawn': Vector2(103, -290)}
	},
	'100003' : {
		'P1': {'map': '100002',
					'spawn': Vector2(904, -252)}
	},
}
