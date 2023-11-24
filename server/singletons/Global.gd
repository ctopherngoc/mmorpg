extends Node

func _ready():
	pass

func store_character_data(player_id, display_name):
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.http, player_container.db_info["token"], player_container.current_character)
	await firebase.completed
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
