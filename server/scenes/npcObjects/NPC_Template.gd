extends KinematicBody2D
var id = "100001"

var rng = RandomNumberGenerator.new()
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT

const GRAVITY = 1600
const SPEED_FACTOR = 0.5
const MOVEMENT_SPEED = 100
var move_state
onready var location = [Vector2(-375,-53),Vector2(-300,-53)]

func _ready():
	pass
	
func _process(delta):
	#print(position)
	if move_state == 0:
		if self.position.x < location[0].x:
			direction = Vector2.RIGHT
		elif self.position.x > location[1].x:
			direction= Vector2.LEFT
		velocity.x = (direction * MOVEMENT_SPEED * SPEED_FACTOR).x
	else:
		velocity.x = 0
		velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Timer_timeout():
	var randi_move = floor(rand_range(0,4))
	# next is idle
	if not move_state in [0,3] and randi_move in [0,3]:
		move_state = randi_move
	# if idle
	elif move_state in [0,3]:
		move_state = randi_move
