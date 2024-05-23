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
onready var http = $HTTPRequest
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
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.http, player_container.db_info.token, player_container.current_character)
	yield(firebase, 'completed')
	#print("%s saved data" % display_name)

func npc_attack(player: KinematicBody2D, monster_stats: Dictionary) -> void:
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
func _on_Timer_timeout() -> void:
	if ServerData.username_list.size() > 0:
		var player_id_arr = Array(ServerData.username_list.keys())
		for player_id in player_id_arr:
			store_character_data(player_id, ServerData.username_list[player_id])
			#print("Stored %s data to firebase db" % ServerData.username_list[player_id])
	#else:
		#print("no players no need to save db")

func send_climb_data(player_id: int, climb_data: int):
	#print("send_climb_data: player_id: %s, climb_data %s" % [typeof(player_id), typeof(climb_data)])
	server.send_climb_data(player_id, climb_data)

func damage_formula(type: bool, player_dict: Dictionary, target_stats: Dictionary) -> int:
	var stats = player_dict.stats
	if stats.base.accuracy + stats.equipment.accuracy < target_stats.avoidability:
		var acc_diff = target_stats.avoidability - (stats.base.accuracy + stats.equipment.accuracy)
		acc_diff = acc_diff / 10
		if rng.randi_range(1,10) < acc_diff:
			print("miss")
			return -1
	#print("Acc >= Avoid")
	var damage = rng.randi_range(stats.base.minRange, stats.base.maxRange)
	#print("damage before: ", damage)
	if type:
		#print("phyiscal")
		if stats.base.maxRange >= target_stats.defense:
			damage = float( damage * 2 - target_stats.defense)
		else:
			damage = float( damage * damage / target_stats.defense)
		#print("damage after %s" % damage)
	#magic damage
	else:
		# update later
		#####################################################################
		#print("magic")
		if stats.base.magic >= target_stats.magicDefense:
			damage = float(stats.base.magic * stats.equipment.magic / target_stats.magicDefense)
		else:
			return 0
		#######################################################################
	damage = damage * ((float(stats.base.damagePercent + stats.equipment.damagePercent) * 0.1) + 1.0)
	#print("after dmg_percent: %s" % damage)
	if target_stats["boss"] == 1:
		damage = damage * ((float(stats.base.bossPercent + stats.equipment.bossPercent) * 0.1) + 1.0)
		#print("After boss percent: %s" % damage)
	var crit_rate = stats.base.critRate + stats.equipment.critRate
	var crit_ratio = calculate_crit(crit_rate)
	var final_damage = int(damage * crit_ratio)
	print("final damage: %s" % final_damage)
	return final_damage

func calculate_crit(crit_rate: int) -> float:
	var crit_number = rng.randi_range(1,100)
	if crit_number <= crit_rate:
		print("crit")
		return 1.3
	else:
		print("no crit")
		return 1.0

func calculate_stats(player_stats: Dictionary) -> void:
	var equipment = player_stats.equipment
	var stats = player_stats.stats
	var equipment_stats = ServerData.static_data.equipment_stats_template.duplicate(true)
	# for every item in equipment dict
# warning-ignore:shadowed_variable
	for item in equipment.keys():
		# for every stat in equipment.stats dict ( not null)
		if equipment[item] is int:
			pass
		else:
			for stat in equipment[item].keys():
				if stat in ["name", "id", "uniqueID", "type", "attackSpeed", "slot", "job", "owner"]:
					continue
				else:
					# add stat value to each stat in temp equipment dict
					#print("%s before: " % stat, equipment_stats[stat])
					
					equipment_stats[stat] += equipment[item][stat]
					#print("%s after: " % stat, equipment_stats[stat])
		# update equipment stats of player_dict
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
			base.maxRange = (base.strength + base.wisdom + base.dexterity + base.luck + equip.strength + equip.wisdom + equip.dexterity + equip.luck) + int((float(equip.attack) * ServerData.static_data.weapon_ratio[equipment.rweapon.type]))
		base.minRange = int(float(base.maxRange) * 0.2)
		#print(base.maxRange)
	else:
		pass

func npc_hit(dmg: int, npc: KinematicBody2D, player: String):
	if dmg <= npc.stats.currentHP:
		npc.stats.currentHP -= dmg
		if str(player) in npc.attackers.keys():
			npc.attackers[str(player)] += dmg
		else:
			npc.attackers[str(player)] = dmg
	else:
		if str(player) in npc.attackers.keys():
			npc.attackers[str(player)] += npc.stats.currentHP
		else:
			npc.attackers[str(player)] = npc.stats.currentHP
		npc.stats.currentHP -= dmg
	# if dead change state and make it unhittable
	if npc.stats.currentHP <= 0:
		npc.state = "Dead"
		for attacker in npc.attackers.keys():
			var highest_attacker = null
			var  damage = null
			# if atacker in map
			if npc.map_id in ServerData.player_location[attacker]:
				#var player_container = get_node("../../Players/%s" % attacker)
				var player_container = get_node(ServerData.player_location[str(attacker)] + "/%s" % str(attacker))
				# xp = rounded (dmg done / max hp) * experience
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
	print("monster: " + npc.name + " health: " + str(npc.stats.currentHP))

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
				#print(item_id, " ", ServerData.itemTable[item_id]["itemType"], ": ", item_value)
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
				var random_unique_id = (((rng.randi_range(10000000, 999999999) + rng.randi_range(100, 10000)) / rng.randi_range(2, 5)) - rng.randi_range(10, 100)) + rng.randi_range(10, 51)
				equip_stats["uniqueID"] = str(random_unique_id)
				
				item_list[item_id] = equip_stats
				#print(equip_stats)
			# etc, material, use
			else:
				# drops 1 use/etc item
				item_list[item_id] = 1
	#print(item_list)
	return item_list

func player_drop_item(player_container: KinematicBody2D, position: Vector2, map: String, tab: String, slot: int, quantity: int) -> void:
	pass
	# get item data
	# create dictionary with item_id: item_dict -> dropspawn requires hashmap of items.keys() dropped
	var item_data = {player_container.current_character.inventory[tab][slot].id: player_container.current_character.inventory[tab][slot]}
	if quantity > 1:
		pass
		# reduce item count
		player_container.current_character.inventory[tab][slot].q -= quantity
		dropSpawn(map, position, item_data, quantity)
		# call drop item -> pass map, location, drop_dict, quantity
	# equipment or drop quantity 1
	else:
		pass
		# call drop item -> pass map, location, drop_dict
		player_container.current_character.inventory[tab][slot] = null
		dropSpawn(map, position, item_data)
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

func dropSpawn(map: String, location: Vector2, item_dict: Dictionary, quantity: int = 1, user_id = null) -> void:
	# user_id could be string or null
	var map_path = "/root/Server/World/Maps/" + str(map) + "/YSort/Items"
	var items = item_dict.keys()
	var map_node = get_node(map_path)
	#print("dropSpawn %s" % item_dict)
	for item in items:
		var new_item = item_scene.instance()
		new_item.position = location
		#new_item.position.y = new_item.position.y
		if user_id != null:
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
		#print("Drop id: %s used for client node.name to spawn and despawn items should be in world state", new_item.id)
		if ServerData.itemTable[item]["itemType"] == "equipment":
			new_item.stats = item_dict[item]
			new_item.stats['id'] = item
		else:
			new_item.amount = item_dict[item]
			new_item.stackable = item_dict[item]
		#print(new_item)
		map_node.add_child(new_item, true)

func lootRequest(player: KinematicBody2D, loot_list: Array) -> void:
	#print("processing loot for %s" % player)
	if loot_list.empty():
		pass
		#print("no items")
	else:
		#print(loot_list)
		# for item area2d in list of item area2ds
		for item in loot_list:
			# get item node
			var item_container = item.get_parent()
			# if another player looted already
			if item_container.looted:
				pass
				#print("item already looted")
			elif item_container.player_owner:
				# if there are owners, if player is owner
				# mark item looted, get player container, queuefree item
				# warning-ignore:unused_variable
				var player_id = player.name
				if player.name== item_container.player_owner and item_container.looted == false:
					#item_container.looted = true
					self.lootDrop(player, item_container)
					# add item to players inventory
					break
				else:
					pass
					#print("%s is not owner of item" % player.current_character.displayname)
			else:
				#item_container.looted = true
				self.lootDrop(player, item_container)
				break

func lootDrop(player: KinematicBody2D, item_container: KinematicBody2D) -> void:
	#print("Looted Item Position: ", item_container.position, ServerData.items[item_container.map])
	if item_container.id == "100000":
		item_container.looted = true
		
		#print( "player gold: %s, drop: %s" %[typeof(player.current_character["inventory"]["100000"]), typeof(item_container.amount)])
		# if resulting gold > int variable capacity (max_int), set gold to max_number
		###########################################################################################
		if player.current_character["inventory"]["100000"] + item_container.amount < 0:
			#print("max gold")
			player.current_character["inventory"]["100000"] = max_int
		# add it to current amount
		else:
			player.current_character["inventory"]["100000"] += item_container.amount
		# update map itemlist
		ServerData.items[item_container.map].erase(item_container.name)
		server.send_loot_data(player.name, {"id": item_container.id})
		server.update_player_stats(player)
		# remove item node from map
		#print("removing %s gold from map list and world list" % item_container.amount)
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
				#print(index)
				# add item to index and update client
				item_container.stats["owner"] = player.current_character.displayname
				inventory_ref[index] = item_container.stats
				# update map itemlist
				ServerData.items[item_container.map].erase(item_container.name)
				server.update_player_stats(player)
				# remove item node from map
				var item_dict = item_container.stats
				#print("item_dict: \n %s" % item_dict)
				http_requests.append([item_dict, player])
				server.send_loot_data(player.name, {"id": item_container.id})
				#add_item_database(item_dict, player)
				item_container.queue_free()
				#print("removing item from map list and world list (not stackable, null at index: %s)" % index)
			# inventory does not have room
			else:
				server.send_client_notification(int(player.name), 0)
				#print("player: %s's equip inventory full" % player.name)
		else:
			# if check if item stackable
			if item_container.stackable:
				# item is in inventory list
				var count = 0
				for item in inventory_ref:
					#print("item: %s" % item)
					# not item slot not empty
					if typeof(item) != TYPE_NIL:
						if item_container.id in item.id:
							item_container.looted = true
							"""
							can add if statement here for max_quantity looting. If inventory.item.q <= max_item
								loot
								queue free
								update
								etc
							else
								send error
							"""
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
							#print("removing item from map list and world list (stackable item is in inventory)")
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
					#print("removing item from map list and world list (stackable not in inventory)")
				# inventory does not have room
				else:
					server.send_client_notification(int(player.name), 0)
					#print("player: %s's inventory full stackable", player.name)
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
					#print("removing item from map list and world list (not stackable, null at index: %s)" % index)
				# inventory does not have room
				else:
					server.send_client_notification(int(player.name), 0)
					#print("player: %s's inventory full not stackable", player.name)
	#ServerData.items[item_container.map].erase(item_container.name)
	
# placeholder functions for item ownership and unique item tracking
func add_item_database(data_dict: Dictionary, player_container: KinematicBody2D) -> void:
	"""
	this function should be called on new item drop is looted. Primarily for equipments to keep track of item ownership
	unique item ownership is important in case of trading.
	"""
	#print("inside add_item_database")
	#print(data_dict)
	#print(player_container)
	data_dict["owner"] = player_container.current_character.displayname
	var path = "items/%s" % (data_dict.id + str(data_dict.uniqueID)) 
	#print(data_dict)
	var firebase = Firebase.update_document(path, player_container.http, player_container.db_info["token"], data_dict)
	yield(firebase, 'completed')
	#print("added %s to firebase. owner is %s" % [data_dict.name, player_container.name])
	
func add_item():
	if http_requests.size() > 0:
		#print("adding item to database")
		var item_argument_array = http_requests[0]
		http_requests.remove(0)
		var request = add_item_database(item_argument_array[0], item_argument_array[1])
		yield(request, "completed")

func add_item_to_world_state(item: KinematicBody2D, map_id: String) -> void:
	# N = drop_id client node name
	ServerData.items[map_id][item.name] = {"P": item.position, "I": item.id, "D": item.just_dropped}
	if item.just_dropped == 1:
		item.just_dropped = 0
	elif item.just_dropped == -1:
		ServerData.items[map_id].erase(item.name)
		item.queue_free()
