extends Sprite

# T: clock : {A: Attack animation}
var attack_dict = {}
var attacking = false
onready var sprite: Array
onready var composite_sprite_node = $CompositeSprite
onready var animation_player = $CompositeSprite/AnimationPlayer
onready var username = $Label

func _physics_process(_delta: float) -> void:
#	if not attack_dict == {}:
#		pass
#		attack()
	pass

func move_player(new_position: Vector2, animation: Dictionary) -> void:
	flip_sprite(animation.d)
	
	if attacking == true:
		pass
	else:
		if animation.a:
			#print("%s is attacking" % self.name)
			attacking = true
			# GameData.weapon_speed[str(GameData.equipmentTable[str(sprite[10])].attackSpeed)]
			animation_player.play("slash", -1, GameData.weapon_speed[str(GameData.equipmentTable[str(sprite[10])].attackSpeed)])
		# if position same
		elif new_position == position:
			if animation["f"] != 0:
				animation_player.play("idle")
			else:
				animation_player.play("jump")
		# if player moved
		else:
			if animation["f"] == 1:
				animation_player.play("walk")
			# is not on floor, y direciton move
			else:
				animation_player.play("jump")
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
	for _i in composite_sprite_node.get_children():
		if _i.name != "AnimationPlayer":
			if d:
				_i.set_flip_h(true)
			else:
				_i.set_flip_h(false)
				
func update_sprite(newSprite: Array) -> void:
	if sprite != newSprite:
		sprite = newSprite
		print("new sprite update")
	composite_sprite_node.update_avatar(sprite)
