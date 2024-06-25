extends Sprite
"""
on instance requirement:
	id: skill -> sprite
	direction: -> player_container/monster direction
"""
onready var id: String
# 1 = right -1 = left
onready var direction: int

# projectile data
var max_speed: int = 600
onready var max_distance: int
var target
var target_hit

onready var ready = 1

onready var hitbox = get_node("Hitbox")
onready var rangebox = get_node("Range")
onready var player
#onready var target_count
onready var skill_level
onready var skill_data

#onready var damageType

func _ready():
	get_closest_target()
	
func _physics_process(delta: float) -> void:
	if not target or skill_data.targetCount[skill_level] > 1:
		position += (max_speed * direction) * Vector2(1,0) * delta
		if direction == 1:
			if abs(self.position.x) > abs(max_distance):
				ready = -1
		else:
			if self.position.x < max_distance:
				ready = -1
		return
	else:
		if direction == 1:
			if abs(self.position.x) > abs(max_distance):
				ready = -1
		else:
			if abs(self.position.x) < abs(max_distance):
				ready = -1
		if is_instance_valid(target) and target.state != "Dead":
			position = position.move_toward(target.position, max_speed * delta)
		else:
			target = null
	
#	if target:
#		if target in hitbox.get_overlapping_areas():
#			print("target hit")
		
func get_closest_target() -> void:
	var enemy_array = rangebox.get_overlapping_areas()
	print(enemy_array)
	#print(enemy_array)
	#print("enemy array: ", enemy_array)
	if not enemy_array.empty():
		if skill_data["targetCount"][skill_level] == 1:
			var closest_target: KinematicBody2D
			var closest_target_distance
			for monster in enemy_array:
				#print("monster: %s" % monster)
				var monster_body = monster.get_parent()
				#print(monster_body)
				# 1 = right -1 = left
				if direction == 1 and self.position.x < monster_body.position.x:
					var distance = distance_squared(monster_body.position)
					#print("distance: %s" % distance)
					if closest_target == null or distance < closest_target_distance:
						closest_target = monster_body
						#print("closests target %s" % closest_target)
						closest_target_distance = distance
				elif direction == -1 and self.position.x > monster_body.position.x:
					var distance = distance_squared(monster_body.position)
					if not closest_target or distance < closest_target_distance:
						closest_target = monster_body
						closest_target_distance = distance
			if closest_target:
				#print("closest target: %s, distance: %s" % [closest_target.name, closest_target_distance])
				target = closest_target
		# more than  one target
		else:
			var closest_targets: Array = []
			var closest_target_distances: Array = []
			for monster in enemy_array:
				var monster_body = monster.get_parent()
				#print(monster_body)
				# 1 = right -1 = left
				if direction == 1 and self.position.x < monster_body.position.x:
					if closest_target_distances.size() < skill_data.targetCount[skill_level]:
						closest_targets.append(monster)
						closest_target_distances.append(distance_squared(monster_body.position))
					else:
						#print("distance: %s" % distance)
						var distance = distance_squared(monster_body.position)
# warning-ignore:unused_variable
						var count = 0
						if distance < closest_target_distances.max():
							var index = closest_target_distances.find(closest_target_distances.max())
							closest_target_distances[index] = distance
							closest_targets[index] = monster_body
				elif direction == -1 and self.position.x > monster_body.position.x:
					if closest_targets.size() < skill_data.targetCount[skill_level]:
						closest_targets.append(monster)
						closest_target_distances.append(distance_squared(monster_body.position))
					else:
						var distance = distance_squared(monster_body.position)
# warning-ignore:unused_variable
						var count = 0
						if distance < closest_target_distances.max():
							var index = closest_target_distances.find(closest_target_distances.max())
							closest_target_distances[index] = distance
							closest_targets[index] = monster_body
				
	# no monsters in range
	else:
		#print("no monsters in range")
		if not max_distance:
# warning-ignore:narrowing_conversion
			max_distance = self.position.x + (max_speed * direction)
			#print("direction %s, max distance %s position %s" % [direction, max_distance, self.position])
	
func distance_squared(monster_position) -> float:
#	print("x: ", self.position.x - monster_position.x)
#	print("x2 ", pow(self.position.x - monster_position.x, 2))
#	print("y: ", self.position.y - monster_position.y)
#	print("y2 ", pow(self.position.y - monster_position.y, 2))
	return pow(pow(self.position.x - monster_position.x, 2) + pow(self.position.y - monster_position.y, 2), 1/2.0)

func _on_Hitbox_area_entered(area):
	print("target: %s hit" % area.get_parent())

	if skill_data.targetCount[skill_level] == 1:
		if area.get_parent() == target:
			hitbox.visible = false
			ready = -1
			monster_hit(area.get_parent())
	else:
		if ready > -1:
			if target_hit.size() == skill_data.targetCount[skill_level]:
				hitbox.set_deferred("disabled", true)
				ready = -1
			else:
				if area.get_parent() in target and not area.get_parent() in target_hit:
					target_hit.append(area.get_parent())
					monster_hit(area.get_parent())

func monster_hit(monster_container) -> void:
	Global.calculate_skill_damage(player, monster_container, self)
	ready = -1

# warning-ignore:unused_argument
func _on_Range_area_entered(area):
	if not target and skill_data.targetCount[skill_level] == 1:
		get_closest_target()
