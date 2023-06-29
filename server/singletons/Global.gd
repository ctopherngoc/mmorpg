extends Node

func _ready():
	pass

func store_character_data(player_id, display_name):
	var player_container = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % display_name, player_container.http, player_container.db_info["token"], player_container.current_character)
	yield(firebase, 'completed')
	print("%s saved after level" % display_name)

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
