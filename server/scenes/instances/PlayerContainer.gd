extends KinematicBody2D

onready var http = $HTTPRequest
onready var http2 = $HTTPRequest2
onready var timer =$Timer
#contains token and id
var db_info = {}

# post firestore convert
var characters = []
var characters_info_list = []
var damage = 10

# contains player data
########
#dud list

#takes int/dex/luck/str values from serverdata.gd
var player_stats
# var player_info
######

var hittable = true
var current_character
var newUserBool

func Attack():
	$AnimationPlayer.play("attack")

func overlappingBodies():
	if $do_damage.get_overlapping_areas().size() > 0:
		var closest = null
		for body in $do_damage.get_overlapping_areas():
			if closest == null:
				closest = body
			else:
				if pow((closest.position.x - self.position.x), 2) > pow((body.position.x - self.position.x ), 2):
					closest = body
				else:
					pass
		
		#print(closest)
		#print(closest.get_parent())
		closest.get_parent().NPCHit(damage, self.name)
		# print(get_node("../../Monsters/%s") % closest.name)
	else:
		pass
func TakeDamage(take_damage):
	if hittable:
		hittable = false
		print(self.name + " takes %s damage" % str(take_damage))
		current_character["stats"]["health"] -= take_damage
		print("Current HP: %s" % current_character["stats"]["health"])
		
		# WIP 
#		if current_character["stats"]["health"] <= 0:
#			print("%s died" % current_character["displayname"])
#			Global.playerDeath(self.name)

		get_node("/root/Server").UpdatePlayerStats(self)
		$DamageTimer.start()
	else:
		pass
		#print("Player I-Frame")
		
func experience(experience):
	print(self.name + " gain %s exp" % str(experience))
	current_character["stats"]["experience"] += experience
	
	# if level up
	if current_character["stats"]["experience"] >= ServerData.experienceTable[str(current_character["stats"]["level"])]:
		current_character["stats"]["experience"] -= ServerData.experienceTable[str(current_character["stats"]["level"])]
		current_character["stats"]["level"] += 1
		current_character["stats"]["sp"] += 5
		print("%s Level Up" % current_character["displayname"])
		
		# add ability point skill points
		if current_character["stats"]["class"] != 0:
			current_character["stats"]["ap"] += 3
			
		Global.storeCharacterInfo(self.name, current_character["displayname"])
		
	print("Level: %s" % current_character["stats"]["level"])
	print("EXP: %s" % current_character["stats"]["experience"])
	get_node("/root/Server").UpdatePlayerStats(self)

#####################################################################################################
## not implemented server knockback
##func recieve_knockback(damage_source_pos: Vector2):
##	var knockback_direction = damage_source_pos.direction_to(self.global_position)
##	var knockback = knockback_direction * knockback_modifier *40	
##	self.global_position += knockback


func _on_DamageTimer_timeout():
	hittable = true
	$DamageTimer.stop()
