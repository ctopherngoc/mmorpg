extends KinematicBody2D

##########################################################
var monster_id = ""
var title = ""
var floating_text = preload("res://scenes/userInerface/FloatingText.tscn")
var current_hp = null
var miss_counter = null
var max_hp
#var state = null
onready var sprite_scale = Vector2(1, 0.4)
var despawn = 1
onready var timer = $Timer
onready var sprite = $Sprite
onready var label = $Label
onready var collision = $CollisionShape2D
onready var dmg_text_height = 10
############################################################

func _ready():
	label.text = title
	collision.scale = sprite_scale

# new functions
func move(new_position, enemy_state, direction):
	if despawn == 1:
		var curr_position = self.get_position()
		#turn right
		if new_position.x > curr_position.x and abs(new_position.x - curr_position.x) > 0.2:
			if direction == 1:
				sprite.scale = Vector2(-.7,.4)
			animation_control('walk')
		#turn left
		elif new_position.x < curr_position.x and abs(new_position.x - curr_position.x) > 0.2:
			if direction == -1:
				sprite.scale = Vector2(.7,.4)
			animation_control('walk')
		else:
			animation_control('idle')
		set_position(new_position)

func damage_taken(health, damage_array: Array) -> void:
	if health > current_hp:
		animation_control("hit")
	current_hp = health
	var lines = 0
	for damage in damage_array:
		var damage_text = floating_text.instance()
		damage_text.position.y -= 35 * lines
		damage_text.type = damage[1]
		damage_text.amount = damage[0]
		add_child(damage_text)
		lines += 1
		health_bar_update()
		yield(get_tree().create_timer(0.1),"timeout")
		

# health bar above monsters head on hit/death, not implemented yet
func health_bar_update():
	pass

func on_death():
	AudioControl.play_audio("deathSquish")
	animation_control("die")
	despawn = 0
	label.visible = false
	#sprite.visible = false
	sprite.modulate = Color8(62,62,62)
	timer.start()
	print("%s died" % self.name)
	yield(timer, "timeout")

func animation_control(animation):
	if animation == 'idle':
		$AnimationPlayer.play("idle")
	elif animation == "die":
		$AnimationPlayer.play("die")
	else:
		$AnimationPlayer.play("walk")

func _on_Timer_timeout():
	self.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	pass # Replace with function body.
