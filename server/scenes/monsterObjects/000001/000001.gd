extends KinematicBody2D

###############################################
# old variables
# no jump, not used
var jump_speed = 500
##########################################################
#currrent new variables
var id = "000001"
var title = "Green Guy"
var location = null
var current_hp = 25
var max_hp = 25
var state = "idle"
var stats = {
	"level": 1,
	"boss": 0,
	#"maxHP": 25,
	#"currentHP": 25,
	"attack" : 10,
	"defense" : 5,
	"magicDefense" : 5,
	"accuracy" : 10,
	"avoidability" : 5,
	"experience": 25,
	"movementSpeed": 100,
	"jumpSpeed": 200,
}
var map_id = null

var rng = RandomNumberGenerator.new()
var max_speed = 100
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var gravity = 1600
var speed_factor = 0.5
var experience = 25
var move_state
var attackers = {}
############################################################

func _ready():
	pass
	
func _process(delta):
	touch_damage()

	# eventually incorperate take damage set aggro
	# skip rng movement algo
	# no jump mechanic yet
	if is_on_floor():
		var _my_random_number = rng.randi_range(1, 100)

		if move_state == 1:
			direction= Vector2.RIGHT
			velocity.x = (direction * max_speed *speed_factor).x

		elif move_state == 2:
			direction= Vector2.LEFT
			velocity.x = (direction * max_speed * speed_factor).x

		else:
			velocity.x = 0

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Timer_timeout():
	move_state = floor(rand_range(0,3))

# enemy container controlled dmg and xp
func npc_hit(dmg, player):
	if dmg <= current_hp:
		current_hp -= dmg
		if str(player) in attackers.keys():
			attackers[str(player)] += dmg
		else:
			attackers[str(player)] = dmg
	else:
		if str(player) in attackers.keys():
			attackers[str(player)] += current_hp
		else:
			attackers[str(player)] = current_hp
		current_hp -= dmg
	# if dead change state and make it unhittable
	if current_hp <= 0:
		state = "Dead"

		for attacker in attackers.keys():
			# if atacker logged in
			if attacker in ServerData.player_location.keys():
				print(str(attacker) + " killed monster")

				# if attacker in map
				if get_node("../../Players/%s" % attacker):
					var player_container = get_node("../../Players/%s" % attacker)

					# xp = rounded (dmg done / max hp) * experience
					var damage_percent = round((attackers[attacker] / max_hp))
					print(attackers[attacker])
					print("% dmg ", damage_percent)
					if damage_percent == 1:
						player_container.experience(experience)
					else:
						player_container.experience(int(round(damage_percent * experience)))
		get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)

	print("monster: " + self.name + " health: " + str(current_hp))

func touch_damage():
	if $do_damage.get_overlapping_areas().size() > 0:
		for player in $do_damage.get_overlapping_areas():
			# call server to do damage to body
			Global.npc_attack(player.get_parent(), stats)

# call in global for univeral dmg xp
func die():
	get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)

