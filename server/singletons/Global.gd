extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func storeCharacterInfo(player_id, displayname):
	var playerContainer = get_node(ServerData.player_location[str(player_id)] + "/%s" % str(player_id))
	var firebase = Firebase.update_document("characters/%s" % displayname, playerContainer.http, playerContainer.db_info["token"], playerContainer.current_character)
	yield(firebase, 'completed')
	print("%s saved after level" % displayname)

func NPCAttack(player, monster_stats):
	#print(player.current_character) 
	#print(monster_stats)
	var player_stats = player.current_character.stats
	#print(player_stats)
	# calculate basic hit mechanic and damage formula
	
	# hit mechanic
	if monster_stats["Accuracy"] >= player_stats["dexterity"] * 1.2:
		#print("Monster Hit: %s" % player.name)
		
		# some random damage formula
		# since theres no player defense use strength as defense
		var calculation = monster_stats["Attack"] - player_stats["strength"]
		if calculation > 1:
			player.TakeDamage(calculation)
		else:
			player.TakeDamage(1)	
	else:
		print("Monster potentially miss")

# WIP
# warning-ignore:unused_argument
func playerDeath(player_id):
	pass
