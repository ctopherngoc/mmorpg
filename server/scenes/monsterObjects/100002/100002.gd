extends KinematicBody2D
var id = '100002'
var location = null
var state = "idle"
var stats = {}

var rng = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var gravity = 1600
var speed_factor = 0.5
var move_state
var attackers = {}

func _ready():
	stats = ServerData.monsterTable[self.id].duplicate(true)
	
func _process(delta):
	touch_damage()

	if is_on_floor():
		var _my_random_number = rng.randi_range(1, 100)

		if move_state == 1:
			direction= Vector2.RIGHT
			velocity.x = (direction * stats.movementSpeed *speed_factor).x

		elif move_state == 2:
			direction= Vector2.LEFT
			velocity.x = (direction * stats.movementSpeed * speed_factor).x

		else:
			velocity.x = 0

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Timer_timeout():
	move_state = floor(rand_range(0,3))


#func npc_hit(dmg, player):
#	current_hp -= dmg
#	if str(player) in attackers.keys():
#		attackers[str(player)] += dmg
#	else:
#		attackers[str(player)] = dmg
#	# if dead change state and make it unhittable
#	if current_hp <= 0:
#		state = "Dead"
#
#		for attacker in attackers.keys():
#			# if atacker logged in
#			if attacker in ServerData.player_location.keys():
#
#				# if attacker in map
#				if get_node("../../Players/%s" % attacker):
#					var player_container = get_node("../../Players/%s" % attacker)
#
#					# xp = rounded (dmg done / max hp) * experience 
#					player_container.experience(int(round((attackers[attacker] / max_hp) * experience)))
#
#		get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
#
#	print("monster: " + self.name + " health: " + str(current_hp))

func touch_damage():
	if $do_damage.get_overlapping_areas().size() > 0:
		for player in $do_damage.get_overlapping_areas():
			# call server to do damage to body
			Global.npc_attack(player.get_parent(), stats)

# call in global for univeral dmg xp
func die():
	get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)

