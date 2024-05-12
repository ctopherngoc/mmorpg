extends KinematicBody2D

##########################################################
var monster_id = "100002"
var title = "Blue Guy"
var current_hp = null
var max_hp = GameData.monsterTable[monster_id].maxHP
var state = null
var xScale = 1.583
var despawn = 1
############################################################

func _ready():
	if state == "Idle":
		pass
	elif state == "Dead":
		# play death animation ( currently just turns sprite black)
		#$Sprite.modulate = Color(0,0,0)
		#Sprite.visible = false
		get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
		get_node("take_damage/CollisionShape2D").set_deferred("disabled", true)

####################################################
# new functions
func move(new_position):
	var curr_position = self.get_global_position()
	#turn right
	if new_position.x > curr_position.x:
		$Sprite.scale.x = xScale * -1
		animation_control('walk')
	#turn left
	elif new_position.x < curr_position.x:
		$Sprite.scale.x = xScale
		animation_control('walk')
	else:
		animation_control('idle')
	set_position(new_position)

func health(health):
	if health != current_hp:
		print(str(self.name) + " took " + str(current_hp - health) + " damage")
		AudioControl.play_audio("squish")
		current_hp = health
		health_bar_update()

# health bar above monsters head on hit/death, not implemented yet
func health_bar_update():
	pass

func on_death():
	AudioControl.play_audio("deathSquish2")
	despawn = 0
	get_node("do_damage/CollisionShape2D").set_deferred("disabled", true)
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("take_damage/CollisionShape2D").set_deferred("disabled", true)
	self.visible = false
	print("%s died" % self.name)
	self.queue_free()

func animation_control(animation):
	if animation == 'idle':
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("walk")
