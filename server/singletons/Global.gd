extends Node
var server = null
var rng = RandomNumberGenerator.new()

func _ready():
	pass
	server = get_node("/root/Server")

func store_character_data(player_id, display_name):
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.http, player_container.db_info["token"], player_container.current_character)
	yield(firebase, 'completed')
	print("%s saved data" % display_name)

func npc_attack(player, monster_stats):
	var player_stats = player.current_character.stats
	# calculate basic hit mechanic and damage formula
	
	# hit mechanic
	if monster_stats["Accuracy"] >= player_stats["dexterity"] * 1.2:
		#print("Monster Hit: %s" % player.name)
		
		# some random damage formula, since theres no player defense use strength as defense
		var calculation = monster_stats["Attack"] - player_stats["strength"]
		if calculation > 1:
			player.take_damage(calculation)
		else:
			player.take_damage(1)	
	else:
		print("Monster potentially miss")

# WIP
# warning-ignore:unused_argument
func player_death(player_id):
	pass

# save all player data to firebase db every 10 minutes
func _on_Timer_timeout():
	if ServerData.username_list.size() > 0:
		var player_id_arr = Array(ServerData.username_list.keys())
		for player_id in player_id_arr:
			store_character_data(player_id, ServerData.username_list[player_id])
			print("Stored %s data to firebase db" % ServerData.username_list[player_id])
	else:
		print("no players no need to save db")

func send_climb_data(player_id, climb_data):
	server.send_climb_data(player_id, climb_data)

# attack is not calculated yet
func damage_formula(type: bool, player_stats: Dictionary, target_stats: Dictionary):
	if player_stats["accuracy"] >= target_stats["avoidability"]:
		print("Acc >= Avoid")
		var crit_ratio = calculate_crit(player_stats["critRate"])
		var damage
		if type:
			print("phyiscal")
			var attack = calculate_attack(type, player_stats)
			damage = float(attack * attack / target_stats["physicalDefense"])
			print("damage %s" % damage)
		#magic damage
		else:
			var magic_attack = calculate_attack(type, player_stats)
			damage = float(magic_attack * magic_attack / target_stats["magicDefense"])
		damage = damage * ((float(player_stats["damagePercent"]) * 0.1) + 1.0)
		print("after dmg_percent: %s" % damage)
		if target_stats["boss"] == 1:
			damage = damage * ((float(player_stats["bossPercent"]) * 0.1) + 1.0)
			print("After boss percent: %s" % damage)
		var final_damage = int(damage * crit_ratio)
		print("final damage: %s" % final_damage)
		return final_damage 
	else:
		print("miss")

func calculate_crit(crit_rate):
	var crit_number = rng.randi_range(1,100)
	if crit_number <= crit_rate:
		print("crit")
		return 1.3
	else:
		print("no crit")
		return 1.0

func calculate_attack(type, player_stats):
	if type:
		if player_stats["job"] == 0:
			var attack = (player_stats["strength"] + player_stats["wisdom"] + player_stats["dexterity"] + player_stats["luck"]) * 2
			print(attack)
			return attack
	else:
		pass
