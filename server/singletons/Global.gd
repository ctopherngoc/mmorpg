######################################################################
# Server-backend Global Singleton. Calculates player movements and combat, item generation and item drop.
# communicates back to client through Server.gd
######################################################################
extends Node
var server = null
var rng = RandomNumberGenerator.new()
var item_scene = preload("res://scenes/instances/Item.tscn")
const max_int = 9223372036854775807
const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
onready var http_requests = []
onready var maps
onready var fb_loaded = false

######################################################################
# testing variables
var testplayer
######################################################################
func _process(_delta: float) -> void:
	add_item()
	
func _ready() -> void:
	server = get_node("/root/Server")

func store_character_data(player_id: String, display_name: String) -> void:
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.db_info.token, player_container.current_character)
	yield(firebase, 'completed')

func npc_attack(player: KinematicBody2D, monster_stats: Dictionary) -> void:
	var player_stats = player.current_character.stats
	if monster_stats.accuracy >= player_stats.base.avoidability + player_stats.equipment.avoidability + player_stats.buff.avoidability:
		var calculation = monster_stats.attack - player_stats.base.defense + player_stats.equipment.defense + player_stats.buff.defense
		if calculation > 1:
			player.take_damage(calculation)
		else:
			player.take_damage(1)	
	else:
		print("Monster potentially miss")

func player_death(player_id):
	print("%s died" % player_id)

# save all player data to firebase db every 10 minutes
func _on_Timer_timeout() -> void:
	if ServerData.username_list.size() > 0:
		var player_id_arr = Array(ServerData.username_list.keys())
		for player_id in player_id_arr:
			store_character_data(player_id, ServerData.username_list[player_id])

func send_climb_data(player_id: int, climb_data: int):
	server.send_climb_data(player_id, climb_data)

func damage_formula(type: bool, player_dict: Dictionary, target_stats: Dictionary, hitAmount: int = 1, damagePercent: float = 1.0) -> int:
	var stats = player_dict.stats
	var damage_list = []
	var count = 0
	while count < hitAmount:
		var damage
		if stats.base.accuracy + stats.equipment.accuracy + stats.buff.accuracy < target_stats.avoidability:
			var acc_diff = target_stats.avoidability - (stats.base.accuracy + stats.equipment.accuracy + stats.buff.accuracy)
			acc_diff = acc_diff / 10
			if rng.randi_range(1,10) < acc_diff:
				damage = "Miss"
				damage_list.append([damage, "M"])
		
		if not damage:
			damage = rng.randi_range(stats.base.minRange, stats.base.maxRange) * damagePercent
			if type:
				if stats.base.maxRange >= target_stats.defense:
					damage = float( damage * 2 - target_stats.defense)
				else:
					damage = float( damage * damage / target_stats.defense)
			#magic damage
			else:
				# update later
				#####################################################################
				if stats.base.magic >= target_stats.magicDefense:
					damage = float(stats.base.magic * stats.equipment.magic * stats.buff.magic / target_stats.magicDefense)
				else:
					damage = 0
				#######################################################################
			damage = damage * ((float(stats.base.damagePercent + stats.equipment.damagePercent + stats.buff.damagePercent) * 0.1) + 1.0)
			if target_stats["boss"] == 1:
				damage = damage * ((float(stats.base.bossPercent + stats.equipment.bossPercent + stats.buff.bossPercent) * 0.1) + 1.0)
			var crit_rate = stats.base.critRate + stats.equipment.critRate + stats.buff.critRate
			var crit_ratio = calculate_crit(crit_rate)
			var final_damage = int(damage * crit_ratio)
			if crit_ratio == 1.0:
				damage_list.append([final_damage, "N"])
			else:
				damage_list.append([final_damage, "C"])
		count += 1
	return damage_list

func calculate_crit(crit_rate: int) -> float:
	var crit_number = rng.randi_range(1,100)
	if crit_number <= crit_rate:
		return 1.3
	else:
		return 1.0

func calculate_stats(player_stats: Dictionary) -> void:
	var equipment = player_stats.equipment
	var stats = player_stats.stats
	var equipment_stats = ServerData.static_data.equipment_stats_template.duplicate(true)
	# for every item in equipment dict
# warning-ignore:shadowed_variable
	for item in equipment.keys():
		# for every stat in equipment.stats dict ( not null)
		if equipment[item] is int or equipment[item] == null:
			pass
		else:
			for stat in equipment[item].keys():
				if stat in ["name", "id", "uniqueID", "type", "attackSpeed", "slot", "job", "owner", "weaponType","reqLevel", "reqStr", "reqLuk", "reqWis", "reqDex",]:
					continue
				else:
					# add stat value to each stat in temp equipment dict
					equipment_stats[stat] += equipment[item][stat]
	stats.equipment = equipment_stats

	# calculate attack based on characer job
	var base = stats.base
	var equip = stats.equipment

	# beginner class 
	# (base stats: int + total equip stats: int) + int(float(total equipment attack: int) * weapon ratio: float)
	if base.job == 0:
		if equipment.rweapon == null:
			base.maxRange = (base.strength + base.wisdom + base.dexterity + base.luck + equip.strength + equip.wisdom + equip.dexterity + equip.luck)
		else:
			base.maxRange = (base.strength + base.wisdom + base.dexterity + base.luck + equip.strength + equip.wisdom + equip.dexterity + equip.luck) + int((float(equip.attack) * ServerData.static_data.weapon_ratio[equipment.rweapon.weaponType]))
		base.minRange = int(float(base.maxRange) * 0.2)
	else:
		pass

func npc_hit(dmg_list: Array, npc: KinematicBody2D, player: KinematicBody2D):
	"""
	change dmg_list to list of lists
	"""
	var miss_counter = 0
	for dmg in dmg_list:
		npc.damage_taken.append(dmg)
		if typeof(dmg[0]) == TYPE_STRING:
			miss_counter += 1
			pass
		elif dmg[0] < npc.stats.currentHP and dmg[0] > 0:
			npc.stats.currentHP -= dmg[0]
			if ServerData.username_list[str(player.name)] in npc.attackers.keys():
				npc.attackers[ServerData.username_list[str(player.name)]] += dmg[0]
			else:
				npc.attackers[ServerData.username_list[str(player.name)]] = dmg[0]
			# apply knockback
			npc.knockback(dmg[0], player.position)
			npc.state = "Hit"
		# its dead
		else:
			if npc.stats.currentHP > 0:
				if ServerData.username_list[str(player.name)] in npc.attackers.keys():
						npc.attackers[ServerData.username_list[str(player.name)]] += npc.stats.currentHP
				else:
					npc.attackers[ServerData.username_list[str(player.name)]] = npc.stats.currentHP
				npc.stats.currentHP = 0
		# if dead change state and make it unhittable
		if npc.stats.currentHP <= 0 and npc.state != "Dead":
			npc.state = "Dead"
			for attacker in npc.attackers.keys():
				var highest_attacker = null
				var  damage = null
				# if atacker in map
				"""
				issue when player relogs -> diff id
				"""
				if npc.map_id in ServerData.player_location[ServerData.ign_id_dict[attacker]]:
					var player_container = get_node(ServerData.player_location[ServerData.ign_id_dict[attacker]] + "/%s" % ServerData.ign_id_dict[attacker])
					var damage_percent = round((npc.attackers[attacker] / npc.stats.maxHP))
					if !highest_attacker:
						highest_attacker = attacker
						damage = damage_percent
					# highest daamge atacker saved
					else:
						if damage_percent > damage:
							highest_attacker = attacker
							damage = damage_percent
					if damage_percent == 1:
						# should be
						# player_container.experience(ServerData.monsterTable[npc.id].experience)
						player_container.experience(npc.stats.experience)
					else:
						player_container.experience(int(round(damage_percent * npc.stats.experience)))
					var drop_list = dropGeneration(npc.id)
					dropSpawn(npc.map_id, npc.position, drop_list, highest_attacker)
			# drop items from npc location
			npc.die()
			# monster die -> check if any quest needs killing tracking
			if self.update_hunt_quest(player.current_character.displayname, npc.id):
				server.update_quest_data(player)
		else:
			pass
	if miss_counter == dmg_list.size():
		npc.miss_counter += 1
	print("monster: " + npc.name + " :health: " + str(npc.stats.currentHP))

func dropGeneration(monster_id: String) -> Dictionary:
	"""
	takes monster_id and calls dropDetemination. If true calculate gold amount, item randoization, item amount
	returns dictionary with item_key : item_details
	"""
	var drop_list = ServerData.monsterTable[monster_id]["dropList"]
	var item_list = {}
	for item_id in drop_list:
		item_id = str(item_id)
		# if drop
		if dropDetermine(item_id):
			# gold
			if ServerData.itemTable[item_id]["itemType"] == "100000":
				var monster_level = ServerData.monsterTable[monster_id]["level"]
				var item_max_value = pow((monster_level + 1),2)
				var item_value = rng.randi_range(item_max_value / 2,item_max_value)
				item_list[item_id] = item_value
			# equip
			elif ServerData.itemTable[item_id]["itemType"] == "equipment":
				var equip_stats = ServerData.equipmentTable[item_id]
				var keys = equip_stats.keys()
				for key in keys:
					if !equip_stats[key]:
						equip_stats[key] = 0
					elif key in ["attack", "magic", "strength","dexterity", "wisdom", "maxHP",
								"maxMana", "movementSpeed", "jumpSpeed", "defense", "magicDefense"]:
						equip_stats[key] += rng.randi_range(-5,5)
						if equip_stats[key] < 0:
							equip_stats[key] = 0
				# create unique id
				var random_unique_id = generate_unique_id(item_id)
				equip_stats["uniqueID"] = str(random_unique_id)
				
				item_list[item_id] = equip_stats
			# etc, material, use
			else:
				# drops 1 use/etc item
				item_list[item_id] = 1
	return item_list

func player_drop_item(player_container: KinematicBody2D, position: Vector2, map: String, tab: String, slot: int, quantity: int) -> void:
	# get item data
	# create dictionary with item_id: item_dict -> dropspawn requires hashmap of items.keys() dropped
	var item_data = {player_container.current_character.inventory[tab][slot].id: player_container.current_character.inventory[tab][slot]}
	var item_dict = player_container.current_character.inventory[tab][slot]
	if ServerData.itemTable[item_dict.id].itemType != "equipment":
		# reduce item count
		player_container.current_character.inventory[tab][slot].q -= quantity
		playerDropSpawn(map, position, item_data, quantity)
		# call drop item -> pass map, location, drop_dict, quantity
	# equipment or drop quantity 1
	else:
		# call drop item -> pass map, location, drop_dict
		player_container.current_character.inventory[tab][slot] = null
		item_dict.owner = null
		http_requests.append([item_dict, player_container])
		playerDropSpawn(map, position, item_data)
	server.update_player_stats(player_container)
	
func dropDetermine(item_id: String) -> bool:
	"""
	function takes drop drate from ServerData itemtable and calculates drop outcome
	returns true/false
	"""
	var drop_rate = ServerData.itemTable[item_id]["dropRate"]
	var rate_roll = randi() % 100 + 1
	if rate_roll <= drop_rate:
		return true
	else:
		return false

# warning-ignore:unused_argument
func dropSpawn(map: String, location: Vector2, item_dict: Dictionary, user_id: String) -> void:
	# user_id could be string or null
	var map_path = "/root/Server/World/Maps/" + str(map) + "/YSort/Items"
	var items = item_dict.keys()
	var map_node = get_node(map_path)
	for item in items:
		var new_item = item_scene.instance()
		new_item.position = location
		new_item.player_owner = user_id
		new_item.id = item
		new_item.map = str(map)
		var node_name = ""
		# sets node name to random string of 6 nums/letters
# warning-ignore:unused_variable
		for i in range(6):
			 node_name += chars[randi() % chars.length()]
		new_item.drop_id = node_name
		new_item.name = new_item.drop_id
		#set stackable
		#default not stackable
		if ServerData.itemTable[item]["stackable"] == 1:
			new_item.stackable = 1
		if ServerData.itemTable[item]["itemType"] == "equipment":
			new_item.stats = item_dict[item]
			new_item.stats['id'] = item
		else:
			new_item.amount = item_dict[item]
			new_item.stackable = item_dict[item]
		map_node.add_child(new_item, true)
		
# warning-ignore:unused_argument
func playerDropSpawn(map: String, location: Vector2, item_dict: Dictionary, quantity: int = 1) -> void:
	# user_id could be string or null
	var map_path = "/root/Server/World/Maps/" + str(map) + "/YSort/Items"
	var items = item_dict.keys()
	var map_node = get_node(map_path)
	for item in items:
		var new_item = item_scene.instance()
		new_item.position = location
		new_item.id = item
		new_item.map = str(map)
		var node_name = ""
		# sets node name to random string of 6 nums/letters
# warning-ignore:unused_variable
		for i in range(6):
			 node_name += chars[randi() % chars.length()]
		new_item.drop_id = node_name
		new_item.name = new_item.drop_id
		#set stackable
		#default not stackable
		if ServerData.itemTable[item]["stackable"] == 1:
			new_item.stackable = 1
		if ServerData.itemTable[item]["itemType"] == "equipment":
			new_item.stats = item_dict[item]
			new_item.stats['id'] = item
		else:
			new_item.amount = item_dict[item]
			new_item.stackable = item_dict[item]
		map_node.add_child(new_item, true)

func lootRequest(player: KinematicBody2D, loot_list: Array) -> void:
	if loot_list.empty():
		player.looting = false
	else:
		# for item area2d in list of item area2ds
		for item in loot_list:
			# get item node
			var item_container = item.get_parent()
			# if another player looted already
			if item_container.looted:
				pass
			elif item_container.player_owner:
				# if there are owners, if player is owner
				# mark item looted, get player container, queuefree item
				# warning-ignore:unused_variable
				var player_id = player.current_character.displayname
				if player_id == item_container.player_owner and item_container.looted == false:
					#item_container.looted = true
					self.lootDrop(player, item_container)
					player.loot_timer.start()
					# add item to players inventory
					break
				else:
					pass
			else:
				#item_container.looted = true
				self.lootDrop(player, item_container)
				player.loot_timer.start()
				break

func lootDrop(player: KinematicBody2D, item_container: KinematicBody2D) -> void:
	if item_container.id == "100000":
		item_container.looted = true
		# if resulting gold > int variable capacity (max_int), set gold to max_number
		###########################################################################################
		if player.current_character["inventory"]["100000"] + item_container.amount < 0:
			player.current_character["inventory"]["100000"] = max_int
		# add it to current amount
		else:
			player.current_character["inventory"]["100000"] += item_container.amount
		# update map itemlist
		ServerData.items[item_container.map].erase(item_container.name)
		server.send_loot_data(player.name, {"id": item_container.id})
		server.update_player_stats(player)
		# remove item node from map
		item_container.queue_free()
		
	# parse if item is etc, use, equip
	else:
		# get reference to player inventory -> item type tab
		# reference is of type Array
		# algorithm to add item into inventory dictionary
		#####var inventory_ref = ServerData.characters_data[str(player.current_character.displayname)]["inventory"][ServerData.itemTable[item_container.id]["itemType"]]
		var inventory_ref = player.current_character["inventory"][ServerData.itemTable[item_container.id]["itemType"]]
		# items without stats dictionary are non-equipment items
		if typeof(item_container.stats) != TYPE_NIL:
			var index = inventory_ref.find(null)
			# inventory has room
			if index >= 0:
				item_container.looted = true
				# add item to index and update client
				item_container.stats["owner"] = player.current_character.displayname
				inventory_ref[index] = item_container.stats
				# update map itemlist
				ServerData.items[item_container.map].erase(item_container.name)
				server.update_player_stats(player)
				# remove item node from map
				#### ISSUE???######
				####################################################################################################
				var item_dict = item_container.stats
				#item_dict.owner = player.current_chracter.displayname
				item_dict.owner = player.name
				#######################################################################################################
				http_requests.append([item_dict, player])
				server.send_loot_data(player.name, {"id": item_container.id})
				item_container.queue_free()
			# inventory does not have room
			else:
				server.send_client_notification(int(player.name), 0)
		else:
			# if check if item stackable
			if item_container.stackable:
				# item is in inventory list
				var count = 0
				for item in inventory_ref:
					# not item slot not empty
					if typeof(item) != TYPE_NIL:
						if item_container.id in item.id:
							item_container.looted = true
							# increment quantity in dictionary
							inventory_ref[count].q += 1
							# update map itemlist (removes item from dictionary using node name)
							# client should have despawn mechanic on loot to queue free
							ServerData.items[item_container.map].erase(item_container.name)
							# update player stats
							server.update_player_stats(player)
							# remove item node from map
							server.send_loot_data(player.name, {"id": item_container.id})
							item_container.queue_free()
							return
						else:
							count += 1
					else:
						count += 1
				# item is not in inventory
				# if player inventory has room (null value): returns index, returns -1 if no room
				var index = inventory_ref.find(null)
				# inventory has room
				if index >= 0:
					item_container.looted = true
					# update map itemlist
					ServerData.items[item_container.map].erase(item_container.name)
					# add item to index and update client
					inventory_ref[index] = {"id": str(item_container.id), "q": 1}
					server.send_loot_data(player.name, {"id": item_container.id})
					server.update_player_stats(player)
					# remove item node from map
					item_container.queue_free()
				# inventory does not have room
				else:
					server.send_client_notification(int(player.name), 0)
			# if look for first open space
			else:
				# if player inventory has room (null value): returns index, returns -1 if no room
				var index = inventory_ref.find(null)
				# inventory has room
				if index >= 0:
					item_container.looted = true
					# update map itemlist
					ServerData.items[item_container.map].erase(item_container.name)
					# add item to index and update client
					inventory_ref[index] = {"id": str(item_container.id), "q": 1}
					server.send_loot_data(player.name, {"id": item_container.id})
					server.update_player_stats(player)
					# remove item node from map
					item_container.queue_free()
				# inventory does not have room
				else:
					server.send_client_notification(int(player.name), 0)

# placeholder functions for item ownership and unique item tracking
func add_item_database(data_dict: Dictionary, player_container: KinematicBody2D = null) -> void:
	var path = "items/%s" % (data_dict.id + str(data_dict.uniqueID)) 
	var firebase = Firebase.update_document(path, player_container.db_info["token"], data_dict)
	yield(firebase, 'completed')
	
func add_item():
	if http_requests.size() > 0:
		var item_argument_array = http_requests[0]
		http_requests.remove(0)
		# [item_dict, player]
		var request = add_item_database(item_argument_array[0], item_argument_array[1])
		yield(request, "completed")

func add_item_to_world_state(item: KinematicBody2D, map_id: String) -> void:
	# N = drop_id client node name
	ServerData.items[map_id][item.name] = {"P": item.position, "I": item.id, "D": item.just_dropped}
	if item.just_dropped == 1:
		item.just_dropped = 0
	elif item.just_dropped == -1:
		ServerData.items[map_id].erase(item.name)
		if ServerData.itemTable[item.id]["itemType"] == "equipment":
			ServerData.equipmentTable.erase(str(item.stats.id) + str(item.stats.uniqueID))
		item.queue_free()

func add_projectile_to_world_state(projectile: Sprite, map_id: String) -> void:
	# N = drop_id client node name
	ServerData.projectiles[map_id][projectile.name] = {"P": projectile.position, "I": projectile.id}
	if projectile.ready == 1:
		projectile.ready = 0
	elif projectile.ready == -1:
		ServerData.projectiles[map_id].erase(projectile.name)
		projectile.queue_free()

func remove_projectiles_in_world_state(projectile_list: Array, map_id: String) -> void:
	var world_state_projectile_list = ServerData.projectiles[map_id].keys()
	var projetile_names = []
	
	for node in projectile_list:
		projetile_names.append(node.name)
	for projectile in world_state_projectile_list:
		if not projectile_list.has(projectile):
			ServerData.projectiles[map_id].erase(projectile)
			
func calculate_skill_damage(player_container: KinematicBody2D, monster_container: KinematicBody2D, projectile_container: Sprite):
	var damage_list = damage_formula(projectile_container.skill_data.damageType, player_container.current_character, monster_container.stats, projectile_container.skill_data.hitAmount[projectile_container.skill_level], projectile_container.skill_data.stat.damagePercent[projectile_container.skill_level])
	npc_hit(damage_list, monster_container, player_container)

func cancel_buff(player_container: KinematicBody2D, skill_id: String):
	# get skill level
	var player_skill_data = player_container.current_character.skills[ServerData.skill_class_dictionary[skill_id].location[0]][ServerData.skill_class_dictionary[skill_id].location[1]]
	var skill_data = ServerData.skill_data[ServerData.skill_class_dictionary[skill_id].location[0]][ServerData.skill_class_dictionary[skill_id].location[1]]
	var keys = skill_data.stat.keys()
	for key in keys:
		if "Percent" in key and "strength" in key:
			player_container.current_character.stats.buff["strength"] -= floor(player_container.current_character.stats.base.strength * skill_data.stat[key][player_skill_data - 1])
		elif "Percent" in key and "dexterity" in key:
			player_container.current_character.stats.buff["dexterity"] -= floor(player_container.current_character.stats.base.dexterity * skill_data.stat[key][player_skill_data - 1])
		elif "Percent" in key and "wisdom" in key:
			player_container.current_character.stats.buff["wisdom"] -= floor(player_container.current_character.stats.base.wisdom * skill_data.stat[key][player_skill_data - 1])
		elif "Percent" in key and "luck" in key:
			player_container.current_character.stats.buff["luck"] -= floor(player_container.current_character.stats.base.luck * skill_data.stat[key][player_skill_data - 1])
		elif "Percent" in key and "health" in key:
			player_container.current_character.stats.buff["maxHealth"] -= floor(player_container.current_character.stats.base.maxHealth * skill_data.stat[key][player_skill_data - 1])
			if player_container.current_character.stats.base.health > player_container.current_character.stats.base.maxHealth + player_container.current_character.stats.buff.maxHealth:
				player_container.current_character.stats.base.health = player_container.current_character.stats.base.maxHealth + player_container.current_character.stats.buff.maxHealth
		elif "Percent" in key and "mana" in key:
			player_container.current_character.stats.buff["maxMana"] -= floor(player_container.current_character.stats.base.maxMana * skill_data.stat[key][player_skill_data - 1])
			if player_container.current_character.stats.base.mana > player_container.current_character.stats.base.maxMana + player_container.current_character.stats.buff.maxMana:
				player_container.current_character.stats.base.mana = player_container.current_character.stats.base.maxMana + player_container.current_character.stats.buff.maxMana
		else:
			player_container.current_character.stats.buff[key] -= skill_data.stat[key][player_skill_data - 1]
	server.update_player_stats(player_container)

func generate_unique_id(item_id) -> int:
	var unique_id = (((rng.randi_range(10000000, 999999999) + rng.randi_range(100, 10000)) / rng.randi_range(2, 5)) - rng.randi_range(10, 100)) + rng.randi_range(10, 51)
	var equipment_id = str(item_id) + str(unique_id)
	while equipment_id in ServerData.equipment_data:
		unique_id = (((rng.randi_range(10000000, 999999999) + rng.randi_range(100, 10000)) / rng.randi_range(2, 5)) - rng.randi_range(10, 100)) + rng.randi_range(10, 51)
		equipment_id = str(item_id) + str(unique_id)
	ServerData.equipment_data.append(equipment_id)
	return unique_id
	
func update_hunt_quest(displayname, monster_id) -> bool:
	# quest data is in ServerData.quest_data[displayname]
	# quest requirements is in ServerData.questTable
	
	# set quest index 
	var update_quests = false
	var quest_id = 0
	# iterate through player quest data
	for quest in ServerData.quest_data.displayname:
		# if current quest started and not ended and is of type hunt
		if quest[0] >= 0 and quest[0] < 9 and ServerData.questTable[quest_id].type == "hunt":
			var index = ServerData.questTable[quest_id].questReq.find(int(monster_id))
			# if monster id in questReq array
			if index != -1:
				# quest_data -> displayname key -> quest index -> requirement index in list == 1 -> index + 1 = actual count -> add one
				# questTable: 0 2 4 6 8 10 12
				# quest_data :0 1 2 3 4  5  6
				if index == 0:
					ServerData.quest_data[displayname][quest_id][1][index] += 1
				else:
					ServerData.quest_data[displayname][quest_id][1][int(index / 2)] += 1
				update_quests = true
				print("%s killed %s monster for %s quest" % [displayname, monster_id, ServerData.questTable[quest_id].title])
		quest_id += 1
	if update_quests:
		return true
	else:
		return false
