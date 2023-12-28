extends Node
var server = null
var rng = RandomNumberGenerator.new()

func _ready():
	pass
	server = get_node("/root/Server")

func store_character_data(player_id, display_name):
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.http, player_container.db_info.token, player_container.current_character)
	yield(firebase, 'completed')
	print("%s saved data" % display_name)

func npc_attack(player, monster_stats):
	var player_stats = player.current_character.stats
	# calculate basic hit mechanic and damage formula
	
	# hit mechanic
	if monster_stats.accuracy >= player_stats.base.avoidability + player_stats.equipment.avoidability:
		var calculation = monster_stats.attack - player_stats.base.defense + player_stats.equipment.defense
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

func damage_formula(type: bool, player_dict: Dictionary, target_stats: Dictionary):
	var stats = player_dict.stats
	if stats.base.accuracy + stats.equipment.accuracy < target_stats.avoidability:
		var acc_diff = target_stats.avoidability - (stats.base.accuracy + stats.equipment.accuracy)
		acc_diff = acc_diff / 10
		if rng.randi_range(1,10) < acc_diff:
			print("miss")
			return -1
	print("Acc >= Avoid")
	var damage = rng.randi_range(stats.base.minRange, stats.base.maxRange)
	print("damage before: ", damage)
	if type:
		print("phyiscal")
		if stats.base.maxRange >= target_stats.defense:
			damage = float( damage * 2 - target_stats.defense)
		else:
			damage = float( damage * damage / target_stats.defense)
		print("damage after %s" % damage)
	#magic damage
	else:
		# update later
		#####################################################################
		print("magic")
		if stats.base.magic >= target_stats.magicDefense:
			damage = float(stats.base.magic * stats.equipment.magic / target_stats.magicDefense)
		else:
			pass
		#######################################################################
	damage = damage * ((float(stats.base.damagePercent + stats.equipment.damagePercent) * 0.1) + 1.0)
	print("after dmg_percent: %s" % damage)
	if target_stats["boss"] == 1:
		damage = damage * ((float(stats.base.bossPercent + stats.equipment.bossPercent) * 0.1) + 1.0)
		print("After boss percent: %s" % damage)
	var crit_rate = stats.base.critRate + stats.equipment.critRate
	var crit_ratio = calculate_crit(crit_rate)
	var final_damage = int(damage * crit_ratio)
	print("final damage: %s" % final_damage)
	return final_damage 

func calculate_crit(crit_rate):
	var crit_number = rng.randi_range(1,100)
	if crit_number <= crit_rate:
		print("crit")
		return 1.3
	else:
		print("no crit")
		return 1.0

func calculate_stats(player_stats):
	var equipment = player_stats.equipment
	var stats = player_stats.stats
	var equipment_stats = ServerData.equipment_stats_template.duplicate(true)
	# for every item in equipment dict
	for item in equipment.keys():
		# for every stat in equipment.stats dict ( not null)
		if equipment[item] is int:
			pass
		else:
			for stat in equipment[item].stats.keys():
				# add stat value to each stat in temp equipment dict
				print("%s before: " % stat, equipment_stats[stat])
				equipment_stats[stat] += equipment[item].stats[stat]
				print("%s after: " % stat, equipment_stats[stat])
		# update equipment stats of player_dict
	stats.equipment = equipment_stats
	
	# calculate attack based on characer job
	var base = stats.base
	var equip = stats.equipment
	
	# beginner class 
	# (base stats: int + total equip stats: int) + int(float(total equipment attack: int) * weapon ratio: float)
	if base.job == 0:
		base.maxRange = (base.strength + base.wisdom + base.dexterity + base.luck + equip.strength + equip.wisdom + equip.dexterity + equip.luck) + int((float(equip.attack) * ServerData.weapon_ratio[equipment.rweapon.type]))
		base.minRange = int(float(base.maxRange) * 0.2)
		print(base.maxRange)
	else:
		pass

func npc_hit(dmg, npc, player):
	if dmg <= npc.current_hp:
		npc.current_hp -= dmg
		if str(player) in npc.attackers.keys():
			npc.attackers[str(player)] += dmg
		else:
			npc.attackers[str(player)] = dmg
	else:
		if str(player) in npc.attackers.keys():
			npc.attackers[str(player)] += npc.current_hp
		else:
			npc.attackers[str(player)] = npc.current_hp
		npc.current_hp -= dmg
	# if dead change state and make it unhittable
	if npc.current_hp <= 0:
		npc.state = "Dead"

		for attacker in npc.attackers.keys():
			# if atacker in map
			if npc.map_id in ServerData.player_location[attacker]:
				#var player_container = get_node("../../Players/%s" % attacker)
				var player_container = get_node(ServerData.player_location[str(attacker)] + "/%s" % str(attacker))
				# xp = rounded (dmg done / max hp) * experience
				var damage_percent = round((npc.attackers[attacker] / npc.max_hp))
				print(npc.attackers[attacker])
				print("% dmg ", damage_percent)
				if damage_percent == 1:
					player_container.experience(npc.experience)
				else:
					player_container.experience(int(round(damage_percent * npc.experience)))
		npc.die()
	print("monster: " + npc.name + " health: " + str(npc.current_hp))
