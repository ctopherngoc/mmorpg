extends KinematicBody2D

onready var http = $HTTPRequest
onready var http2 = $HTTPRequest2
onready var timer =$Timer
onready var idle_timer =$idle_timer
#contains token and id
var db_info = {}
var cur_position = Vector2.ZERO

# post firestore convert
var email = ""
var characters = []
var characters_info_list = []
var damage = 10
var idle_counter = 0

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

func attack():
	$AnimationPlayer.play("attack")

func overlapping_bodies():
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

		closest.get_parent().npc_hit(damage, self.name)
	else:
		pass
func take_damage(take_damage):
	if hittable:
		hittable = false
		print(self.name + " takes %s damage" % str(take_damage))
		current_character["stats"]["health"] -= take_damage
		print("Current HP: %s" % current_character["stats"]["health"])
		
		# WIP 
#		if current_character["stats"]["health"] <= 0:
#			print("%s died" % current_character["displayname"])
#			Global.player_death(self.name)

		get_node("/root/Server").update_player_stats(self)
		$DamageTimer.start()
	else:
		pass
		#print("Player I-Frame")
		
func experience(experience):
	print(self.name + " gain %s exp" % str(experience))
	var current_exp = current_character["stats"]["experience"]
	var exp_limit = ServerData.experience_table[str(current_character["stats"]["level"])]
	current_exp += experience
	
	# if level up
	if current_exp >= exp_limit:
		current_exp -= exp_limit
		current_character["stats"]["level"] += 1
		current_character["stats"]["sp"] += 5
		print("%s Level Up" % current_character["displayname"])
		
		# add ability point skill points
		if current_character["stats"]["class"] != 0:
			current_character["stats"]["ap"] += 3
			
		Global.store_character_data(self.name, current_character["displayname"])
		
	print("Level: %s" % current_character["stats"]["level"])
	print("EXP: %s" % current_character["stats"]["experience"])
	get_node("/root/Server").update_player_stats(self)

#####################################################################################################
## not implemented server knockback
##func recieve_knockback(damage_source_pos: Vector2):
##	var knockback_direction = damage_source_pos.direction_to(self.global_position)
##	var knockback = knockback_direction * knockback_modifier *40	
##	self.global_position += knockback


func _on_DamageTimer_timeout():
	hittable = true
	$DamageTimer.stop()

func start_idle_timer():
	$idle_timer.start(1.0)
	print("idle timer start")
	
# regen 5hp every 5 seconds if idle
func _on_idle_timer_timeout():
	#print(cur_position, self.position)
	if self.position != cur_position:
		cur_position = self.position
		idle_counter = 0
	else:
		# print("same position")
		if self.is_on_floor():
			idle_counter += 1
			if idle_counter == 5:
				if current_character["stats"]["health"] < current_character["stats"]["maxHealth"]:
					if current_character["stats"]["maxHealth"] - current_character["stats"]["health"] < 5:
						var hp_dif = current_character["stats"]["maxHealth"] - current_character["stats"]["health"]
						current_character["stats"]["health"] += int(hp_dif)
					else:
						print("heal 5 hp")
						current_character["stats"]["health"] += 5
					get_node("/root/Server").update_player_stats(self)
				else:
					pass
				idle_counter = 0
		else:
			idle_counter = 0
