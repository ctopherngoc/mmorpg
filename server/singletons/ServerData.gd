extends Node
var player_location = {}
var username_list = {}
var player_state_collection = {}

# current emails logged in
var logged_emails = []

# dictionary player_id: email
# maybe not needed
var player_id_emails = {}
var multiLogIn = []

var skill_data

# temp data for stat menu on client, should be converted to character info
var test_data = {
	"Stats" : {
		"Strength" : 42,
		"Vitality" : 68,
		"Dexterity" : 37,
		"Intelligence" : 24,
	}
}
#var user_template = {'characters':{'arrayValue':{'values': null }}}

#firebase used to create new chracters
var player_info = {
	"displayname": {'stringValue': null},
	"lastmap": {'stringValue': null},
	"position": {'doubleValue':null},
	"stats" : { "mapValue":
		{"fields": {
			"maxHealth": {'doubleValue': null},
			"health": {'doubleValue': null},
			"maxMana": {'doubleValue': null},
			"mana": {'doubleValue': null},
			"level": {'doubleValue': null},
			"experience": {'doubleValue': null},
			"class": {'doubleValue': null},
			"job": {'doubleValue': null},
			"sp": {'doubleValue': null},
			"ap": {'doubleValue': null},
			"strength": {'doubleValue': null},
			"wisdom": {'doubleValue': null},
			"dexterity": {'doubleValue': null},
			"luck": {'doubleValue': null},
			"movementSpeed": {'doubleValue': null},
			"jumpSpeed": {'doubleValue': null},
			"avoidability": {'doubleValue': null},
			"weaponDefense": {'doubleValue': null},
			"magicDefense": {'doubleValue': null},
			"accuracy": {'doubleValue': null},
		}#fields
		}#mapvalue
		}, #stats
	"equipment" : {"mapValue":
		{"fields": 
			{"hat": {'doubleValue': null},
			"top": {'doubleValue': null},
			"bottom": {'doubleValue': null},
			"gloves": {'doubleValue': null},
			"shoes": {'doubleValue': null},
			"weapon": {'doubleValue': null},
			}#fields
			}#mapvalue
			}, #equipment
	"inventory" : {"mapValue":
		{"fields": 
			{"money": {'doubleValue': null},
			}#fields
			}#mapvalue
			} #inventory
}

# used by server
var player_template = {
	"displayname": null,
	"lastmap": "res://scenes/maps/BaseLevel.tscn",
	"position": 0,
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
		}, #stats
	"equipment" : {
			"hat": 0,
			"top": 0,
			"bottom": 0,
			"gloves": 0,
			"shoes": 0,
			"weapon": 0,
			}, #equipment
	"inventory" : {
				"money": 0,
			} #inventory
}

# possible to convert map monster dictionary and spawn position
var monsters = {
	"000001" : {},
	"000002" : {},
	"000003" : {},
	"000004" : {},
}

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
	"000001": {
		'P1': {'map': '000002',
					'spawn': Vector2(103, -290)},
	},
	'000002': {
		'P1': {'map': '000001',
					'spawn': Vector2(833, -89)},
		'P2': {'map': '000003',
					'spawn': Vector2(103, -290)}
	},
	'000003' : {
		'P1': {'map': '000002',
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
