extends Sprite

# T: clock : {A: Attack animation}
var attack_dict = {}
var attacking = false
onready var sprite: Array
onready var composite_sprite_node = $CompositeSprite
#onready var animation_player = $CompositeSprite/AnimationPlayer
onready var username = $Label

func _physics_process(_delta: float) -> void:
#	if not attack_dict == {}:
#		pass
#		attack()
	pass

func move_player(new_position: Vector2, animation: Dictionary) -> void:
	if animation.a > 0:
		print(animation)
	flip_sprite(animation.d)
	
	if attacking == true:
		pass
	else:
		if animation.a:
			#print("%s is attacking" % self.name)
			attacking = true
			composite_sprite_node.normal_anim.play("slash", -1, GameData.weapon_speed[str(GameData.equipmentTable[str(sprite[10])].attackSpeed)])
		# if position same
		elif new_position == position:
			if animation["c"] == 1:
				composite_sprite_node.set_climb()
				#composite_sprite_node.climb_anim.play("climb")
			elif animation["f"] != 0:
				composite_sprite_node.unset_climb()
				composite_sprite_node.normal_anim.play("idle")
#			else:
#				composite_sprite_node.climb_anim.play("climb")
		# if player moved
		else:
			if animation["c"] == 1:
				composite_sprite_node.set_climb()
				composite_sprite_node.climb_anim.play("climb")
			elif animation["f"] == 1:
				composite_sprite_node.unset_climb()
				composite_sprite_node.normal_anim.play("walk")
			# is not on floor, y direciton move
			else:
				composite_sprite_node.unset_climb()
				composite_sprite_node.normal_anim.play("jump")
	set_position(new_position)
		
#func attack():
#	for attack in attack_dict.keys():
#		print("there is an attack in dict")
#		if attack <= Server.client_clock:
#			print("before attacking animation")
#			attacking = true
## warning-ignore:unused_variable
#			var animation = $AnimationPlayer.play("stab")
#			print("other player attack done")
#			attack_dict.erase(attack)

func flip_sprite(d):
	for _i in composite_sprite_node.normal.get_children():
		if _i.name != "AnimationPlayer":
			if d == -1:
				_i.set_flip_h(true)
			else:
				_i.set_flip_h(false)
				
func update_sprite(newSprite: Array) -> void:
	#print(newSprite)
	if sprite != newSprite:
		sprite = newSprite
		#print("new sprite update")
	composite_sprite_node.update_avatar(sprite)
