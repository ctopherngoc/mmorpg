extends Node2D

onready var normal = $Normal
onready var normal_anim = $Normal/AnimationPlayer
onready var ammo = $Normal/Ammo
onready var body = $Normal/Body
onready var bottom = $Normal/Bottom
onready var brow = $Normal/Brow
onready var eye = $Normal/Eye
onready var eyeacc = $Normal/Eyeacc
onready var faceacc = $Normal/Faceacc
onready var hair = $Normal/Hair
onready var head = $Normal/Head
onready var headgear  = $Normal/Headgear
onready var larm = $Normal/Larm
onready var lear = $Normal/Lear
onready var learring = $Normal/Learring
onready var lfinger = $Normal/Lfinger
onready var lglove = $Normal/LGlove
onready var lhand = $Normal/Lhand
onready var lleg = $Normal/Lleg
onready var lwep = $Normal/LWeapon
onready var mouth = $Normal/Mouth
onready var rarm = $Normal/Rarm
onready var rear = $Normal/Rear
onready var rearring = $Normal/Rearring
onready var rglove = $Normal/RGlove
onready var rhand = $Normal/Rhand
onready var rleg = $Normal/Rleg
onready var rwep = $Normal/Rweapon
onready var top = $Normal/Top
onready var tattoo = $Normal/Tattoo
onready var pocket = $Normal/Pocket

onready var climb_sprite = $Climb
onready var climb_anim = $Climb/AnimationPlayer
onready var climb_ammo = $Climb/Ammo
onready var climb_body = $Climb/Body
onready var climb_bottom = $Climb/Bottom
onready var climb_hair = $Climb/Hair
onready var climb_headgear  = $Climb/Headgear
onready var climb_ears = $Climb/Ears
onready var climb_earrings = $Climb/Earrings
onready var climb_gloves = $Climb/Gloves
onready var climb_top = $Climb/Top

# no rfinger
onready var sprite_dict = {
	"ammo" : ammo,
	"body" : body,
	"bottom": bottom,
	"brow" : brow,
	"eye": eye,
	"eyeacc": eyeacc,
	"faceacc": faceacc,
	"headgear": headgear,
	"learring": learring,
	"lglove:": lglove,
	"lleg": lleg,
	"lweapon": lwep,
	"pocket": pocket,
	"rearring": rearring,
	"rglove": rglove,
	"rleg": rleg,
	"rweapon": rwep,
	"top": top,
	"tattoo": tattoo,
	"rarm": rarm,
	"larm": larm,
}

onready var climb_sprite_dict = {
	"ammo" : climb_ammo,
	"body" : climb_body,
	"bottom": climb_bottom,
	"headgear": climb_headgear,
	"earring": climb_earrings,
	"glove": climb_gloves,
	"top": climb_top,
}

onready var item_map = {
	7: "headgear",
	8: "top",
	9: "bottom",
	10: "rweapon",
	11: "lweapon",
	12: "eyeacc",
	13: "earring",
	14: "faceacc",
	15: "glove",
	16: "tattoo",
}

func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	pass
	
# warning-ignore:unused_argument
func update_avatar(data: Array) -> void:
	#body
	var sprite = load(GameData.avatar_sprite.body + str(data[0]) + ".png")
	body.set_texture(sprite)
	sprite = load(GameData.climb_sprite.body + str(data[0]) + "c.png")
	climb_body.set_texture(sprite)
	#arms
	sprite = load(GameData.avatar_sprite.rarm + str(data[0][0]) + ".png")
	rarm.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.larm + str(data[0][0]) + ".png")
	larm.set_texture(sprite)
	#legs
	sprite = load(GameData.avatar_sprite.rleg + str(data[0][0]) + ".png")
	rleg.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.lleg + str(data[0][0]) + ".png")
	lleg.set_texture(sprite)
	#hands
	sprite = load(GameData.avatar_sprite.rhand + str(data[0][0]) + ".png")
	rhand.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.lhand + str(data[0][0]) + ".png")
	lhand.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.lfinger + str(data[0][0]) + ".png")
	lfinger.set_texture(sprite)
	#brow
	sprite = load(GameData.avatar_sprite.brow + str(data[1]) + ".png")
	brow.set_texture(sprite)
	#ear
	sprite = load(GameData.avatar_sprite.rear + str(data[2]) + ".png")
	rear.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.lear + str(data[2]) + ".png")
	lear.set_texture(sprite)
	sprite = load(GameData.climb_sprite.ear + str(data[2]) + ".png")
	climb_ears.set_texture(sprite)
	#eye
	sprite = load(GameData.avatar_sprite.eye + str(data[3]) + ".png")
	eye.set_texture(sprite)
	#hair
	sprite = load(GameData.avatar_sprite.hair + str(data[4]) + ".png")
	hair.set_texture(sprite)
	sprite = load(GameData.climb_sprite.hair + str(data[4]) + "c.png")
	climb_hair.set_texture(sprite)
	#head
	sprite = load(GameData.avatar_sprite.head + str(data[5]) + ".png")
	head.set_texture(sprite)
	#mouth
	sprite = load(GameData.avatar_sprite.mouth + str(data[6]) + ".png")
	mouth.set_texture(sprite)
	
	var index = 7
	var empty_sprite = load(GameData.equipment_sprite.default + "empty_16_11_spritesheet.png")
	var empty_sprite2 = load(GameData.equipment_sprite.default + "empty_16_1_spritesheet.png")
	while index < 17:
		if data[index] == null:
			if item_map[index] == "earring":
				rearring.set_texture(empty_sprite)
				learring.set_texture(empty_sprite)
				climb_earrings.set_texture(empty_sprite2)
				
			elif item_map[index] == "glove":
				lglove.set_texture(empty_sprite)
				rglove.set_texture(empty_sprite)
				climb_gloves.set_texture(empty_sprite2)
			else:
				sprite_dict[item_map[index]].set_texture(sprite)
				
			if item_map[index] in ["headgear", "top", "bottom"]:
					if item_map[index] == "headgear":
						climb_sprite_dict[item_map[index]].set_texture(empty_sprite2)
					elif item_map[index] == "top":
						climb_sprite_dict[item_map[index]].set_texture(empty_sprite2)
					elif item_map[index] == "bottom":
						climb_sprite_dict[item_map[index]].set_texture(empty_sprite2)
						
			index += 1

		else:
			if item_map[index] in ["earring", "glove"]:
				if item_map[index] == "earring":
					sprite = load(GameData.equipment_sprite[rearring] + str(data[index])+".png")
					rleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite[learring] + str(data[index])+".png")
					lleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite.earring + str(data[index])+"c.png")
					climb_earrings.set_texture(sprite)

				elif item_map[index] == "glove":
					sprite = load(GameData.equipment_sprite[rglove] + str(data[index])+".png")
					rleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite[lglove] + str(data[index])+".png")
					lleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite.glove + str(data[index])+"c.png")
					climb_gloves.set_texture(sprite)

			else:
				sprite = load(GameData.equipment_sprite[item_map[index]] + str(data[index])+".png")
				sprite_dict[item_map[index]].set_texture(sprite)
				
				if item_map[index] in ["headgear", "top", "bottom"]:
						if item_map[index] == "headgear":
							if str(data[index]) in GameData.full_headgear_list:
					
								brow.visible = false
								eye.visible = false
								eyeacc.visible = false
								faceacc.visible = false
								hair.visible = false
								learring.visible = false
								mouth.visible = false
								rearring.visible = false
								tattoo.visible = false
								climb_hair.visible = false
								climb_ears.visible = false
								climb_earrings.visible = false
							
							else:
								brow.visible = true
								eye.visible = true
								eyeacc.visible = true
								faceacc.visible = true
								hair.visible = true
								learring.visible = true
								mouth.visible = true
								rearring.visible = true
								tattoo.visible = true
								climb_hair.visible = true
								climb_ears.visible = true
								climb_earrings.visible = true

							sprite = load(GameData.equipment_sprite[item_map[index]]  + str(data[index])+"c.png")
							climb_sprite_dict[item_map[index]].set_texture(sprite)
						elif item_map[index] == "top":
							sprite = load(GameData.equipment_sprite[item_map[index]]  + str(data[index])+"c.png")
							climb_sprite_dict[item_map[index]].set_texture(sprite)
						elif item_map[index] == "bottom":
							sprite = load(GameData.equipment_sprite[item_map[index]]  + str(data[index])+"c.png")
							climb_sprite_dict[item_map[index]].set_texture(sprite)
			index += 1

# warning-ignore:unused_argument
func change_equipment(equipment_slot, item_id):
	pass

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "slash":
		self.get_parent().attacking = false


func set_climb() -> void:
	normal.visible = false
	climb_sprite.visible = true

func unset_climb() -> void:
	normal.visible = true
	climb_sprite.visible = false
	
