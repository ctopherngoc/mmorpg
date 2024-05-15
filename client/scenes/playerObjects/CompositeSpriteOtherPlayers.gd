extends Node2D

onready var ammo = $Ammo
onready var body = $Body
onready var bottom = $Bottom
onready var brow = $Brow
onready var eye = $Eye
onready var eyeacc = $Eyeacc
onready var faceacc = $Faceacc
onready var hair = $Hair
onready var head = $Head
onready var headgear  = $Headgear
onready var larm = $Larm
onready var lear = $Lear
onready var learring = $Learring
onready var lfinger = $Lfinger
onready var lglove = $LGlove
onready var lhand = $Lhand
onready var lleg = $Lleg
onready var lwep = $LWeapon
onready var mouth = $Mouth
onready var rarm = $Rarm
onready var rear = $Rear
onready var rearring = $Rearring
onready var rglove = $RGlove
onready var rhand = $Rhand
onready var rleg = $Rleg
onready var rwep = $Rweapon
onready var top = $Top
onready var tattoo = $Tattoo
onready var pocket = $Pocket

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
	#brow
	sprite = load(GameData.avatar_sprite.brow + str(data[1]) + ".png")
	brow.set_texture(sprite)
	#ear
	sprite = load(GameData.avatar_sprite.rear + str(data[2]) + ".png")
	rear.set_texture(sprite)
	sprite = load(GameData.avatar_sprite.lear + str(data[2]) + ".png")
	lear.set_texture(sprite)
	#eye
	sprite = load(GameData.avatar_sprite.eye + str(data[3]) + ".png")
	eye.set_texture(sprite)
	#hair
	sprite = load(GameData.avatar_sprite.hair + str(data[4]) + ".png")
	hair.set_texture(sprite)
	#head
	sprite = load(GameData.avatar_sprite.head + str(data[5]) + ".png")
	print("head %s" % str(data[5]))
	head.set_texture(sprite)
	#mouth
	sprite = load(GameData.avatar_sprite.mouth + str(data[6]) + ".png")
	mouth.set_texture(sprite)
	
	var index = 7
	while index < 17:
		if str(data[index]) == "-1":
			print("update_avatar compositespriteotherplayer")
			sprite = load(GameData.equipment_sprite.default + "empty_16_11_spritesheet.png")
			if item_map[index] == "earring":
				rearring.set_texture(sprite)
				learring.set_texture(sprite)
				rearring.visible = false
				learring.visible = false
				
			elif item_map[index] == "glove":
				lglove.set_texture(sprite)
				rglove.set_texture(sprite)
				lglove.visible = false
				rglove.visible = false
			else:
				sprite_dict[item_map[index]].set_texture(sprite)
				# for now toggle visibility
				(print("visible off"))
				sprite_dict[item_map[index]].visible = false
			index += 1

		else:
			if item_map[index] == "earring":
				sprite = load(GameData.equipment_sprite[rearring] + str(data[index])+".png")
				rleg.set_texture(sprite)
				sprite = load(GameData.equipment_sprite[learring] + str(data[index])+".png")
				lleg.set_texture(sprite)

			elif item_map[index] == "glove":
				sprite = load(GameData.equipment_sprite[rglove] + str(data[index])+".png")
				rleg.set_texture(sprite)
				sprite = load(GameData.equipment_sprite[lglove] + str(data[index])+".png")
				lleg.set_texture(sprite)

			else:
				sprite = load(GameData.equipment_sprite[item_map[index]] + str(data[index])+".png")
				sprite_dict[item_map[index]].set_texture(sprite)
			sprite_dict[item_map[index]].visible = true
			index += 1

# warning-ignore:unused_argument
func change_equipment(equipment_slot, item_id):
	pass

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "slash":
		self.get_parent().attacking = false
