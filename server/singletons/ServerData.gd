extends Node
var player_location = {}
var username_list = {}
var player_state_collection = {}
var monsters = {
	"100001" : {},
	"100002" : {},
	"100003" : {},
	"100004" : {},
}

# current emails logged in
var logged_emails = []
var player_id_emails = {}

var class_dict = {
	0: {"job": "Beginner", "Weapon": [], "Range": 0},
	1: {"job": "Warrior", "Weapon": ["sword", "hammer", "axe"], "Range": 0},
	2: {"job": "Rouge", "Weapon" : ["dagger"], "Range": 0},
	3: {"job": "Archer", "Weapon" : ["bow"], "Range": 1},
	4: {"job": "Magician", "Weapon" : [], "Range": 0},
	5: {"job": "Gunner", "Weapon" : ["gun"], "Range": 1},
}

var class_skills = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: [],
	5: [],
}

#var user_template = {'characters':{'arrayValue':{'values': null }}}
#firebase used to create new chracters
var player_info = {
	"displayname": {'stringValue': null},
	"map": {'stringValue': null},
	"stats" : { "mapValue":
		{"fields": {
			"maxHealth": {'integerValue': null},
			"health": {'integerValue': null},
			"maxMana": {'integerValue': null},
			"mana": {'integerValue': null},
			"level": {'integerValue': null},
			"experience": {'integerValue': null},
			"class": {'integerValue': null},
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
			"weaponDefense": {'integerValue': null},
			"magicDefense": {'integerValue': null},
			"accuracy": {'integerValue': null},
			"bossPercent": {'integerValue': null},
			"dmgPercent": {'integerValue': null},
			"critRate": {'integerValue': null},
		}#fields
		}#mapvalue
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
	"inventory" : {"mapValue":
		{"fields": 
			{"money": {'integerValue': null},
			}#fields
			}#mapvalue
			} #inventory
}

# used by server
var player_template = {
	"displayname": null,
	"map": "100001",
	"stats" : {
			"health": 50,
			"mana": 50,
			"maxHealth": 50,
			"maxMana": 50,
			"level": 1,
			"experience": 0,
			"class": 0,
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
			"weaponDefense": 0,
			"magicDefense": 0,
			"accuracy": 10,
			"bossPercent": 1,
			"dmgPercent": 1,
			"critRate": 5,
		}, #stats
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
			"weapon": -1,
			"rweapon": -1,
			"pocket": -1,
			"tattoo": -1,
			}, #equipment
	"inventory" : {
				"money": 0,
			} #inventory
}

var starter_equips = [
	[500000, 500001],
	[500002, 500003],
	[500004, 500005],
]

var experience_table = {
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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var skill_data_file = File.new()
#	skill_data_file.open("res://Data/SkillData - Sheet1.json", File.READ)
#	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
#	skill_data_file.close()
#	skill_data = skill_data_json.result

var test_pstats = {
			"health": 50,
			"mana": 50,
			"maxHealth": 50,
			"maxMana": 50,
			"level": 1,
			"experience": 0,
			"class": 0,
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
			"weaponDefense": 0,
			"magicDefense": 0,
			"accuracy": 10,
			"bossPercent": 1,
			"damagePercent": 1,
			"critRate": 5,
		}
var test_mstats = {
			"health": 50,
			"mana": 50,
			"maxHealth": 50,
			"maxMana": 50,
			"level": 1,
			"movementSpeed": 100,
			"jumpSpeed": 200,
			"avoidability": 4,
			"physicalDefense": 16,
			"magicDefense": 1,
			"accuracy": 10,
			"boss": 0
}
