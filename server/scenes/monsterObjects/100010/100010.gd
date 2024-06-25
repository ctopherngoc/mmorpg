extends KinematicBody2D
var id = "100010"
var location = null
var map_id = null
var state = "idle"
var stats = {}
var damage_taken: Array = []
onready var parent
onready var miss_counter = 0

var rng = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var gravity = 1600
var speed_factor = 0.5
var move_state
var attackers = {}
onready var hit_timer = $Timer2
onready var target_node
onready var target_position
onready var sprite_scale = Vector2(0.7, 0.4)

func _ready():
	stats = ServerData.monsterTable[self.id].duplicate(true)
	self.scale = sprite_scale
	
func _process(delta):
	if self.scale != sprite_scale:
		self.scale = sprite_scale
	touch_damage()
	
	if state != "hit":
		if is_on_floor():
			#var _my_random_number = rng.randi_range(1, 100)
			var target = get_target()
			if target != "none":
				if not target_node:
					target_node = get_node(ServerData.player_location[ServerData.ign_id_dict[target]] + "/%s" % ServerData.ign_id_dict[target])
					target_position = get_distance_from_target(target_node)
				# if target does not change or new target
				if target == target_node.current_character.displayname:
					# if not at destination target_position -> keep moving towards it
					#print(self.position, " ",target_position)
					if floor(self.position.x) != floor(target_position.x):
						#print("here")
						var current_position = self.position
						position = position.move_toward(target_position, stats.movementSpeed * delta * speed_factor)
						# walking into wall
						#print(self.position, " ", current_position)
						if floor(self.position.x) == floor(current_position.x):
							if if_player_in_map(target):
								target_position = get_distance_from_target(target_node)
							else:
								target = null
								target_position = null
						elif abs(self.position.x - target_node.position.x) > 80:
							target_position = get_distance_from_target(target_node)
					# if at destination -> get new location to move to -> move
					else:
						print("ontop")
						# player_container still in scene, player ign in dict, player in same map
						target_position = get_distance_from_target(target_node)
						position = position.move_toward(target_position, stats.movementSpeed * delta * speed_factor)
				
				# if new target != previous target
				else:
					var target_node = get_node(ServerData.player_location[ServerData.ign_id_dict[target]] + "/%s" % ServerData.ign_id_dict[target])
					target_position = get_distance_from_target(target_node)
					position = position.move_toward(target_position, stats.movementSpeed * delta * speed_factor)
			else:
				if move_state == 1:
					direction = Vector2.RIGHT
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

func touch_damage():
	if $do_damage.get_overlapping_areas().size() > 0:
		for player in $do_damage.get_overlapping_areas():
			# call server to do damage to body
			Global.npc_attack(player.get_parent(), stats)

# call in global for univeral dmg xp
func die():
	get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
	get_node("take_damage/CollisionShape2D").set_deferred("disabled", true)

func update_state() -> void:
	parent.enemy_list[int(self.name)]["DamageList"] = damage_taken.duplicate(true)
	damage_taken.clear()
	
func knockback(dmg: int) -> void:
	pass

func _on_Timer2_timeout() -> void:
	self.state = "idle"

func start_hit_timer() -> void:
	hit_timer.start()
	
func get_target() -> String:
	if attackers.empty():
		return "none"
	else:
		var players = attackers.keys()
		if players.size() == 1:
			if if_player_in_map(players[0]):
				return players[0]
			else:
				return "none"
		else: 
			var highest_player
			var highest_damage
			for player in players:
				if not highest_player:
					highest_player = player
					highest_damage = attackers[player]
				else:
					if attackers[player] > highest_damage:
						if if_player_in_map(player):
							highest_player = player
							highest_damage = attackers[player]
			return highest_player
			
func get_distance_from_target(target_node) -> Vector2:
	if target_node.position.x > self.position.x:
		return Vector2(target_node.position.x + 50, self.position.y) 
	elif target_node.position.x < self.position.x:
		return Vector2(target_node.position.x - 50, self.position.y)
	else:
		if direction.x == 1:
			return Vector2(self.position.x + 50, self.position.y)
		else:
			return Vector2(self.position.x - 50, self.position.y)
		
func if_player_in_map(display_name) -> bool:
	if ServerData.ign_id_dict.has(display_name):
		if map_id in ServerData.player_location[ServerData.ign_id_dict[display_name]] + "/%s" % ServerData.ign_id_dict[display_name]:
			return true
	return false
