extends KinematicBody2D
"""
1. create ladders end height higher than player height (must jump to climb)
2. make rope 2darea talller than floor
3. holding up while on ground and in area2d does nothing
*** 
"""
# player signals
signal died
# warning-ignore:unused_signal
signal do_damage

# timer for iframes
onready var timer = get_node("Timer")

# dynamic player variables
onready var player
onready var jumpSpeed
onready var health
onready var maxHorizontalSpeed
onready var velocity = Vector2.ZERO
onready var damage

# static player varaibles
onready var horizontalAcceleration = 3
onready var knockback_modifier = 0.2
onready var gravity = 800

# player states
export var climbing = false
export var isClimbing = false
export var noColZone = false
onready var direction = "RIGHT"
onready var tookDamage = false
onready var attacking = false
onready var received_knockback = false
onready var player_state

onready var animation = {
	"f": 1,
	"d": 1
}


func _ready():
	#Server.fetchPlayerDamage(get_instance_id())
	timer.set_wait_time(1.5)
	player = Global.register_player()
	$Label.text = player.displayname
	maxHorizontalSpeed = (player.stats.movementSpeed)
	
	jumpSpeed = (player.stats.jumpSpeed)
# warning-ignore:return_value_discarded
	$take_damage.connect("area_entered", self, "on_hazard_area_entered")
	#$take_damage.connect("area_exited", self, "on_hazard_area_exit")
	get_node( "Head" ).set_flip_h( true )
	get_node( "Body" ).set_flip_h( true )
	get_node( "Ears" ).set_flip_h( true )
	get_node( "Arm" ).set_flip_h( true )
	get_node( "Weapon" ).scale.x = -1

func _physics_process(delta):
	MovementLoop(delta)
	DefinePlayerState()
	updateHPDisplay()

func DefinePlayerState():
	player_state = {"T": Server.client_clock, "P": get_global_position(), "M": Global.current_map, "A": animation}
	Server.SendPlayerState(player_state)

func MovementLoop(delta):
	#take_damage()
	changeDirection()
	var moveVector = get_movement_vector()
	
	# change get velocity
	get_velocity(moveVector, delta)
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
	
	# player state if jumping
	if is_on_floor():
		animation["f"] = 1
	else:
		animation["f"] = 0
	
	if is_on_floor() or !isClimbing:
		velocity = move_and_slide(velocity, Vector2.UP)
	if isClimbing:
		velocity.x = 0
	
	#animation["animation_vector"] = velocity.normalized()
		
	update_animation()

func get_movement_vector():
	#print(self.global_position)
	var moveVector = Vector2.ZERO
	
	# calculating x vector
	# allow x-axis jump off ropes or idle on floor
	if (!attacking && is_on_floor()) or (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")) and Input.get_action_strength("jump"):
		moveVector.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * .8
	else:
		moveVector.x = 0	
		
	# calculating y vector
	# allow jump off ropes
	if isClimbing:
		if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")) and Input.get_action_strength("jump"):
			moveVector.y = -1
		else:
			moveVector.y = 0
	else:
		if Input.get_action_strength("jump") && !attacking:
			moveVector.y = -1
		else:
			moveVector.y = 0
			
	return moveVector

func get_velocity(moveVector, delta):
	velocity.x += moveVector.x * horizontalAcceleration
	# slow down movement
	if(moveVector.x == 0):
		# allows forward jumping
		if(is_on_floor()):
			velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
#		else:
#			velocity.x = lerp(0, velocity.x, pow(2, -1 * delta))
		
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	if climbing:
		if isClimbing:
			velocity.y = 0
			if Input.is_action_pressed("ui_up"):
				velocity.y = -100
			elif Input.is_action_pressed("ui_down"):
				velocity.y = 100
				if is_on_floor():
					isClimbing = false
			# jump off rope
			elif Input.is_action_pressed("jump") && (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
				isClimbing = false
				velocity.y = moveVector.y * jumpSpeed * .8
				velocity.x = moveVector.x * 200
				
		# can climb but not climbing
		else:
#			self.set_collision_layer_bit(0, true)
#			self.set_collision_mask_bit(0, true)

			# if moving
			if (moveVector.y < 0 && is_on_floor()):
					velocity.y = moveVector.y * jumpSpeed
			# press up on ladder initiates climbing
			elif (!is_on_floor() && Input.is_action_pressed("ui_up")) or (is_on_floor() && Input.is_action_pressed("ui_down")):
					isClimbing = true
					self.set_collision_layer_bit(0, false)
					self.set_collision_mask_bit(0, false)
					velocity.y = 0
					velocity.x = 0	
			# over lapping ladder pressing nothing allows gravity
			else:
				velocity.y += gravity * delta
	# not climbable state
	else:
		# normal movement
		if (moveVector.y < 0 && is_on_floor()):
			velocity.y = moveVector.y * jumpSpeed
		else:
			velocity.y += gravity * delta
			
	if !climbing:
		isClimbing = false

# attack > jump > walking > takeDamage > standing
func update_animation():
	var moveVec = get_movement_vector()
	
	if(attacking):
		pass

	elif(Input.is_action_pressed("attack") && !isClimbing):
		$AnimationPlayer.playback_speed = 0.75
		attacking = true
		$AnimationPlayer.play("stab")

	else:
		$AnimationPlayer.playback_speed = 1.0
		if(!is_on_floor()):
			$AnimationPlayer.play("jump")

		elif(moveVec.x != 0):
			$AnimationPlayer.play("walk")
	#	elif(tookDamage):
	#		$Head.play("hit")
	#		$Arm.play("hit")
	#		$Body.play("hit")
	#		$Ears.play("hit")
	#		$RightH.play("idle")
	#		$LeftH.play("hit")
	#		$RightHHit.play('hit')

		else:
			$AnimationPlayer.play("idle")

func changeDirection():
	if Input.is_action_pressed("move_right") && !attacking && !Input.is_action_pressed("move_left"):
		direction = "RIGHT"
		get_node( "Head" ).set_flip_h( true )
		get_node( "Body" ).set_flip_h( true )
		get_node( "Ears" ).set_flip_h( true )
		get_node( "Arm" ).set_flip_h( true )
		get_node( "Weapon" ).scale.x = -1
		get_node("do_damage").scale.x = 1
		animation["d"] = 1
	elif Input.is_action_pressed("move_left") && !attacking && !Input.is_action_pressed("move_right"):
		direction = "LEFT"

		get_node( "Head" ).set_flip_h( false )
		get_node( "Body" ).set_flip_h( false )
		get_node( "Ears" ).set_flip_h( false )
		get_node( "Arm" ).set_flip_h( false )
		get_node( "Weapon" ).scale.x = 1
		get_node("do_damage").scale.x = -1
		animation["d"] = 0
	
######################################################################################
# functions to work on
#################################
#knock back function
# warning-ignore:unused_argument
func on_hazard_area_entered(area2d):
	pass
	#recieve_knockback(area2d.global_position)
	

# warning-ignore:unused_argument
func recieve_knockback(damage_source_pos: Vector2):
	pass
	
#	var knockback_direction = damage_source_pos.direction_to(self.global_position)
#	var knockback = knockback_direction * knockback_modifier *40	
#	self.global_position += knockback

#######################################################################################
# take damage function
func take_damage():
	if !tookDamage:
		if $take_damage.get_overlapping_areas().size() > 0:
			# print("player damage from server %s" % damage)
			#player.stats.mapValue.fields.health.doubleValue -= damage

			print("touch damage. HP = ", player.stats.mapValue.fields.health.doubleValue)
			tookDamage = true
		
			if (player.stats.mapValue.fields.health.doubleValue <= 0):
				# respawn hp
				tookDamage = false
				player.stats.mapValue.fields.health.doubleValue = 25
				print("died update")
				Global.update_player(player)
				emit_signal("died")
			else:
				$take_damage.set_monitoring(false) 
				timer.start()
		else:
			pass
	else:
		pass

func _on_Timer_timeout():
	timer.stop()
	tookDamage = false
	$take_damage.set_monitoring(true) 

# insert iFrame
func on_hazard_area_exit(_area2d):
	if $take_damage.get_overlapping_areas().size() == 0:
		print("no overlapping bodies")

#########################################################################################
# floor collision while in air
func _on_Area2D_area_entered(_area):
	noColZone = true
	self.set_collision_layer_bit(0, false)
	self.set_collision_mask_bit(0, false)
	print("no col")

func _on_Area2D_area_exited(_area):
	noColZone = false
	self.set_collision_layer_bit(0, true)
	self.set_collision_mask_bit(0, true)
	print("col")
##########################################################################################
# attacking functions

func setDamage(s_damage):
	damage = s_damage
	print("player set damage = %s" % s_damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "stab":
		attacking = false
		
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		Server.SendAttack()

func overlappingBodies():
	#print('inside overlappingbodies')
	print("area ovlapping: " + str($do_damage.get_overlapping_areas().size()))
	for body in $do_damage.get_overlapping_areas():
		#if body.is_in_group('enemy'):
		print(body)

func updateHPDisplay():
	$HP.text = str(player["stats"]["health"])
