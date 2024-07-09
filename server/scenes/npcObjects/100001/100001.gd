extends KinematicBody2D
var id = "100001"

var rng = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT

const GRAVITY = 1600
const SPEED_FACTOR = 0.5
const MOVEMENT_SPEED = 100
var move_state
var move_locations = []
var destination
var location = [Vector2(-475,-53),Vector2(-425,-53)]
	
func _process(delta):
	#print(position)
	if move_state == 0:
		if destination == move_locations[0]:
			direction = Vector2.RIGHT
			velocity.x = (direction * MOVEMENT_SPEED * SPEED_FACTOR).x
		else:
			direction= Vector2.LEFT
			velocity.x = (direction * MOVEMENT_SPEED * SPEED_FACTOR).x
	else:
		velocity.x = 0
		velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if position == location[0]:
		destination = location[1]
	elif position == location[1]:
		destination = location[0]

func _on_Timer_timeout():
	var randi_move = floor(rand_range(0,3))
	# next is idle
	if not move_state in [0,3] and randi_move in [0,3]:
		move_state = randi_move
	# if idle
	elif move_state in [0,3]:
		move_state = randi_move
