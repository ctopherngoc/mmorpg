extends KinematicBody2D

#signal monster_died
#signal monster

###############################################
# old variables
var maxSpeed = 100
var velocity = Vector2.ZERO
var direction = Vector2.RIGHT
var gravity = 1600
var jumpSpeed = 500
var rng = RandomNumberGenerator.new()
var speedFactor = 0.5
var move_state
#var hp = 25
#onready var damage
onready var take_damage = false
##########################################################
#currrent new variables
#var location = null
var current_hp = null
var max_hp = null
var state = null
var xScale = 1.583
var despawn = 1
############################################################

func _ready():
# warning-ignore:return_value_discarded
	$take_damage.connect("area_entered", self, "on_hazard_area_entered")
	#Server.fetchMonsterDamage(get_instance_id())
	if state == "Idle":
		pass
	elif state == "Dead":
		#
		# play death animation ( currently just turns sprite black)
		#$Sprite.modulate = Color(0,0,0)
		#Sprite.visible = false
		#
		get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
		get_node("take_damage/CollisionShape2D").set_deferred("disabled", true)

func _on_Timer_timeout():
	move_state = floor(rand_range(0,3))# Replace with function body.

#func setDamage(s_damage):
#	damage = s_damage
#	take_damage = true
#	print("monster set damage = %s" % damage)
		
#func on_hazard_area_entered(_area2d):
#	pass
#	if take_damage:
#		hp -= damage
#
#		if hp > 0:
#			print("monster took 15 dmg")
#		else:
#			emit_signal("monster_died")
#	else:
#		pass

####################################################
# new functions
func MoveMonster(new_position):
	var curr_position = self.get_global_position()
	#turn right
	if new_position.x > curr_position.x:
		$Sprite.scale.x = xScale * -1
	#turn left
	elif new_position.x < curr_position.x:
		$Sprite.scale.x = xScale
	set_position(new_position)

func Health(health):
	if health != current_hp:
		print(str(self.name) + " took " + str(current_hp - health) + " damage")
		current_hp = health
		HealthBarUpdate()
#		if current_hp <= 0:
#			OnDeath()

# healthbar above monsters head on hit/death
# not implemented yet
func HealthBarUpdate():
	pass
	
# if you kill
func OnDeath():
	despawn = 0
	get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("take_damage/CollisionShape2D").set_deferred("disabled", true)
	self.visible = false
	print("%s died" % self.name)
	self.queue_free()
	#z_index = -1
