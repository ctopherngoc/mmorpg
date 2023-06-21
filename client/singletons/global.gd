# possible fix to server dc
# https://www.reddit.com/r/godot/comments/b4sv3l/how_do_i_reload_a_singleton_from_code/
# resets singleton
"""
If you want to restart singleton's scritpt, use: YourSingleton.set_script(null)
then YourSingleton.set_script(preload("res://path_to_script.gd"))
"""

extends Node

var player_spawn = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
onready var mosnter_spawn
var last_world_state = 0
var world_state_buffer = []
onready var current_map = ""
const interpolation_offset = 100

var character_list = []
var player = null
var door_name = null
onready var stringValidation = [
	"4r5e",
	"5h1t",
	"5hit",
	"a55",
	"anal",
	"anus",
	"ar5e",
	"arrse",
	"arse",
	"ass",
	"ass-fucker",
	"asses",
	"assfucker",
	"assfukka",
	"asshole",
	"assholes",
	"asswhole",
	"a_s_s",
	"b!tch",
	"b00bs",
	"b17ch",
	"b1tch",
	"ballbag",
	"balls",
	"ballsack",
	"bastard",
	"beastial",
	"beastiality",
	"bellend",
	"bestial",
	"bestiality",
	"bi+ch",
	"biatch",
	"bitch",
	"bitcher",
	"bitchers",
	"bitches",
	"bitchin",
	"bitching",
	"bloody",
	"blow job",
	"blowjob",
	"blowjobs",
	"boiolas",
	"bollock",
	"bollok",
	"boner",
	"boob",
	"boobs",
	"booobs",
	"boooobs",
	"booooobs",
	"booooooobs",
	"breasts",
	"buceta",
	"bugger",
	"bum",
	"bunny fucker",
	"butt",
	"butthole",
	"buttmuch",
	"buttplug",
	"c0ck",
	"c0cksucker",
	"carpet muncher",
	"cawk",
	"chink",
	"cipa",
	"cl1t",
	"clit",
	"clitoris",
	"clits",
	"cnut",
	"cock",
	"cock-sucker",
	"cockface",
	"cockhead",
	"cockmunch",
	"cockmuncher",
	"cocks",
	"cocksuck",
	"cocksucked",
	"cocksucker",
	"cocksucking",
	"cocksucks",
	"cocksuka",
	"cocksukka",
	"cok",
	"cokmuncher",
	"coksucka",
	"coon",
	"cox",
	"crap",
	"cum",
	"cummer",
	"cumming",
	"cums",
	"cumshot",
	"cunilingus",
	"cunillingus",
	"cunnilingus",
	"cunt",
	"cuntlick",
	"cuntlicker",
	"cuntlicking",
	"cunts",
	"cyalis",
	"cyberfuc",
	"cyberfuck",
	"cyberfucked",
	"cyberfucker",
	"cyberfuckers",
	"cyberfucking",
	"d1ck",
	"damn",
	"dick",
	"dickhead",
	"dildo",
	"dildos",
	"dink",
	"dinks",
	"dirsa",
	"dlck",
	"dog-fucker",
	"doggin",
	"dogging",
	"donkeyribber",
	"doosh",
	"duche",
	"dyke",
	"ejaculate",
	"ejaculated",
	"ejaculates",
	"ejaculating",
	"ejaculatings",
	"ejaculation",
	"ejakulate",
	"f u c k",
	"f u c k e r",
	"f4nny",
	"fag",
	"fagging",
	"faggitt",
	"faggot",
	"faggs",
	"fagot",
	"fagots",
	"fags",
	"fanny",
	"fannyflaps",
	"fannyfucker",
	"fanyy",
	"fatass",
	"fcuk",
	"fcuker",
	"fcuking",
	"feck",
	"fecker",
	"felching",
	"fellate",
	"fellatio",
	"fingerfuck",
	"fingerfucked",
	"fingerfucker",
	"fingerfuckers",
	"fingerfucking",
	"fingerfucks",
	"fistfuck",
	"fistfucked",
	"fistfucker",
	"fistfuckers",
	"fistfucking",
	"fistfuckings",
	"fistfucks",
	"flange",
	"fook",
	"fooker",
	"fuck",
	"fucka",
	"fucked",
	"fucker",
	"fuckers",
	"fuckhead",
	"fuckheads",
	"fuckin",
	"fucking",
	"fuckings",
	"fuckingshitmotherfucker",
	"fuckme",
	"fucks",
	"fuckwhit",
	"fuckwit",
	"fudge packer",
	"fudgepacker",
	"fuk",
	"fuker",
	"fukker",
	"fukkin",
	"fuks",
	"fukwhit",
	"fukwit",
	"fux",
	"fux0r",
	"f_u_c_k",
	"gangbang",
	"gangbanged",
	"gangbangs",
	"gaylord",
	"gaysex",
	"goatse",
	"God",
	"god-dam",
	"god-damned",
	"goddamn",
	"goddamned",
	"hardcoresex",
	"hell",
	"heshe",
	"hoar",
	"hoare",
	"hoer",
	"homo",
	"hore",
	"horniest",
	"horny",
	"hotsex",
	"jack-off",
	"jackoff",
	"jap",
	"jerk-off",
	"jism",
	"jiz",
	"jizm",
	"jizz",
	"kawk",
	"knob",
	"knobead",
	"knobed",
	"knobend",
	"knobhead",
	"knobjocky",
	"knobjokey",
	"kock",
	"kondum",
	"kondums",
	"kum",
	"kummer",
	"kumming",
	"kums",
	"kunilingus",
	"l3i+ch",
	"l3itch",
	"labia",
	"lmfao",
	"lust",
	"lusting",
	"m0f0",
	"m0fo",
	"m45terbate",
	"ma5terb8",
	"ma5terbate",
	"masochist",
	"master-bate",
	"masterb8",
	"masterbat*",
	"masterbat3",
	"masterbate",
	"masterbation",
	"masterbations",
	"masturbate",
	"mo-fo",
	"mof0",
	"mofo",
	"mothafuck",
	"mothafucka",
	"mothafuckas",
	"mothafuckaz",
	"mothafucked",
	"mothafucker",
	"mothafuckers",
	"mothafuckin",
	"mothafucking",
	"mothafuckings",
	"mothafucks",
	"mother fucker",
	"motherfuck",
	"motherfucked",
	"motherfucker",
	"motherfuckers",
	"motherfuckin",
	"motherfucking",
	"motherfuckings",
	"motherfuckka",
	"motherfucks",
	"muff",
	"mutha",
	"muthafecker",
	"muthafuckker",
	"muther",
	"mutherfucker",
	"n1gga",
	"n1gger",
	"nazi",
	"nigg3r",
	"nigg4h",
	"nigga",
	"niggah",
	"niggas",
	"niggaz",
	"nigger",
	"niggers",
	"nob",
	"nob jokey",
	"nobhead",
	"nobjocky",
	"nobjokey",
	"numbnuts",
	"nutsack",
	"orgasim",
	"orgasims",
	"orgasm",
	"orgasms",
	"p0rn",
	"pawn",
	"pecker",
	"penis",
	"penisfucker",
	"phonesex",
	"phuck",
	"phuk",
	"phuked",
	"phuking",
	"phukked",
	"phukking",
	"phuks",
	"phuq",
	"pigfucker",
	"pimpis",
	"piss",
	"pissed",
	"pisser",
	"pissers",
	"pisses",
	"pissflaps",
	"pissin",
	"pissing",
	"pissoff",
	"poop",
	"porn",
	"porno",
	"pornography",
	"pornos",
	"prick",
	"pricks",
	"pron",
	"pube",
	"pusse",
	"pussi",
	"pussies",
	"pussy",
	"pussys",
	"rectum",
	"retard",
	"rimjaw",
	"rimming",
	"s hit",
	"s.o.b.",
	"sadist",
	"schlong",
	"screwing",
	"scroat",
	"scrote",
	"scrotum",
	"semen",
	"sex",
	"sh!+",
	"sh!t",
	"sh1t",
	"shag",
	"shagger",
	"shaggin",
	"shagging",
	"shemale",
	"shi+",
	"shit",
	"shitdick",
	"shite",
	"shited",
	"shitey",
	"shitfuck",
	"shitfull",
	"shithead",
	"shiting",
	"shitings",
	"shits",
	"shitted",
	"shitter",
	"shitters",
	"shitting",
	"shittings",
	"shitty",
	"skank",
	"slut",
	"sluts",
	"smegma",
	"smut",
	"snatch",
	"son-of-a-bitch",
	"spac",
	"spunk",
	"s_h_i_t",
	"t1tt1e5",
	"t1tties",
	"teets",
	"teez",
	"testical",
	"testicle",
	"tit",
	"titfuck",
	"tits",
	"titt",
	"tittie5",
	"tittiefucker",
	"titties",
	"tittyfuck",
	"tittywank",
	"titwank",
	"tosser",
	"turd",
	"tw4t",
	"twat",
	"twathead",
	"twatty",
	"twunt",
	"twunter",
	"v14gra",
	"v1gra",
	"vagina",
	"viagra",
	"vulva",
	"w00se",
	"wang",
	"wank",
	"wanker",
	"wanky",
	"whoar",
	"whore",
	"willies",
	"willy",
	"xrated",
	"xxx"
  ];

# loads player info
func _ready():
	pass

# scene gets player info
func register_player():
	return player

# update global player with scene player changes	
#func update_player(in_player):
#	player = in_player
#	# print('in global.update_player')
#	# print(player)

func update_lastmap(map):
	player.lastmap = map
	
func change_background():
	VisualServer.set_default_clear_color(Color(0.4,0.4,0.4,1.0))
		
func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _physics_process(_delta):
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1 && Server.serverStatus:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		# has future state
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[0]["T"])
				# possibly change iteration from "player" to something else
			for playerState in world_state_buffer[2]["P"].keys():
				#edited
				if playerState == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1]["P"].has(playerState):
					continue
				if world_state_buffer[1]["P"][playerState]["M"] == Global.current_map:
					# currently if other character scene is in client
					# move their character
					# this should be later be determined by the server
					if get_node("/root/currentScene/OtherPlayers").has_node(str(playerState)):
						var new_position = lerp(world_state_buffer[1]["P"][playerState]["P"], world_state_buffer[2]["P"][playerState]["P"], interpolation_factor)
						var animation = world_state_buffer[2]["P"][playerState]["A"]
						get_node("/root/currentScene/OtherPlayers/" + str(playerState)).MovePlayer(new_position, animation)
					
					# check if character map == client map
					else:
						print("Spawning Player")
						SpawnNewPlayer(playerState, world_state_buffer[2]["P"][playerState])
				else:
					DespawnPlayer(playerState)
			# map keys can be empty
			if world_state_buffer[2]["E"][current_map].size() > 0:
				#spawn monsters function
				for monster in world_state_buffer[2]["E"][current_map].keys():
					if not world_state_buffer[1]["E"][current_map].has(monster):
						continue
					# monster not dead on client
					if get_node("/root/currentScene/Monsters").has_node(str(monster)):
						# monster dead on server
						if world_state_buffer[2]["E"][current_map][monster]["EnemyHealth"] <= 0:
							if get_node("/root/currentScene/Monsters/" + str(monster)).despawn != 0:
								get_node("/root/currentScene/Monsters/" + str(monster)).OnDeath()
						# monster alive: update monster stats and position
						else:
							var new_position = lerp(world_state_buffer[1]["E"][current_map][monster]["EnemyLocation"], world_state_buffer[2]["E"][current_map][monster]["EnemyLocation"], interpolation_factor )
						# ######################################################################################
							get_node("/root/currentScene/Monsters/" + str(monster)).MoveMonster(new_position)
							get_node("/root/currentScene/Monsters/" + str(monster)).Health(world_state_buffer[1]["E"][current_map][monster]["EnemyHealth"])
					else:
						# if actually alive respawned monster
						if world_state_buffer[2]["E"][current_map][monster]['time_out'] != 0 && world_state_buffer[2]["E"][current_map][monster]['EnemyState'] != "Dead":
							SpawnNewMonster(monster, world_state_buffer[2]["E"][current_map][monster])
			# we have no future world_state
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for playerState in world_state_buffer[1]["P"].keys():
				if playerState == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0]["P"].has(playerState):
					continue
				if world_state_buffer[0]["P"][playerState]["M"] == Global.current_map:
					# currently if other character scene is in client
					# move their character
					# this should be later be determined by the server
					if get_node("/root/currentScene/OtherPlayers").has_node(str(playerState)):
						var position_delta = (world_state_buffer[1]["P"][playerState]["P"] - world_state_buffer[0]["P"][playerState]["P"])
						var new_position = world_state_buffer[1]["P"][playerState]["P"] + (position_delta * extrapolation_factor)
						var animation = world_state_buffer[1]["P"][playerState]["A"]
						get_node("/root/currentScene/OtherPlayers/" + str(playerState)).MovePlayer(new_position, animation)

#####################################################################
#Spawn/Despawn player/monsters
#player id is now player container
func SpawnNewPlayer(player_id, player_state):
	if player_id == get_tree().get_network_unique_id():
		pass
	else:
	# elif map in Global.player['lastmap']:
		var new_player = Global.player_spawn.instance()
		new_player.position = Vector2(100, -250)
		new_player.name = str(player_id)
		#print(get_node("/root/currentScene/OtherPlayers"))
		get_node("/root/currentScene/OtherPlayers").add_child(new_player)
		get_node("/root/currentScene/OtherPlayers/%s/Label" % player_id).text = player_state["U"]
		
		#####
		#change cahracter label to player_state["U"]

func DespawnPlayer(player_id):
	if get_node("/root/currentScene/OtherPlayers").has_node(str(player_id)):
		print("despawning %s" % player_id)
		get_node("/root/currentScene/OtherPlayers/%s" % str(player_id)).queue_free()
		
func SpawnNewMonster(monster_id, monster_dict):
	var new_monster = get_node("/root/currentScene").monsterScene.instance()
	new_monster.position = monster_dict["EnemyLocation"]
	new_monster.max_hp = monster_dict["EnemyMaxHealth"]
	new_monster.current_hp = monster_dict["EnemyHealth"]
	new_monster.state = monster_dict["EnemyState"]
	#new_monster.despawn = 0
	#add later
#	new_monster.type = monster_dict["EnemyLocation"]
#	new_monster.speed = monster_dict["EnemyLocation"]

	new_monster.name = str(monster_id)
	get_node("/root/currentScene/Monsters").add_child(new_monster, true)

#################################################################################
