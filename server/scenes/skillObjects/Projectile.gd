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
var max_speed: int = 200
onready var max_distance: int
var target

onready var ready

onready var hitbox = get_node("Hitbox")
onready var rangebox = get_node("Range")

func _ready():
	get_closest_target(target)
	
func _physics_process(delta: float) -> void:
	if not target:
		position += (max_speed * direction) * Vector2.rotated(rotation) * delta
		if abs(self.position.x) > abs(max_distance):
			ready = -1
		return
	else:
		position = position.move_toward(target.position, (direction * max_speed) * delta)
		
func get_closest_target(target) -> void:
	var closest_target: Sprite
	var cloest_target_distance: float
	var enemy_array = rangebox.get_overlapping_areas()
	if not enemy_array.empty():
		for monster in rangebox.get_overlapping_areas():
			var monster_body = monster.get_parent().get_parent()
			# 0 = right 1 = left
			if direction == 1 and monster_body.position.x < self.position.x:
				var distance = distance_squared(monster_body.position)
				if not closest_target or distance < closest_target:
					closest_target = monster_body
					cloest_target_distance = distance
			elif direction == -1 and monster_body.position.x > self.position.x:
				var distance = distance_squared(monster_body.position)
				if not closest_target or distance > closest_target:
					closest_target = monster_body
					cloest_target_distance = distance
	# no monsters in range
	else:
		max_distance = self.position.x + (max_speed * direction)
	
func distance_squared(monster_position) -> float:
	return pow(pow(self.position.x - monster_position.x, 2) + pow(self.position.y - monster_position.y, 2), 1/2)

func _on_Hitbox_area_entered(area):
	if area.get_parent().get_parent() == target:
		hitbox.visible = false
		ready = -1
