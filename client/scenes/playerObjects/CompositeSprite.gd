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


var avatar = null
var equipment = null
func _ready():
	#avatar = GameData.test_player.avatar
	#equipment = GameData.test_player.equipment
	avatar = Global.player.avatar
	equipment = Global.player.equipment
	update_avatar("avatar")
	update_avatar("equipment")

# warning-ignore:unused_argument
func _physics_process(delta):
	#update_avatar("equipment")
	pass
	#avatar_check()
	
# warning-ignore:unused_argument
func update_avatar(data):
	if data == "avatar":
		#body
		var sprite = load(GameData.avatar_sprite.body + str(avatar['bcolor']) + str(avatar['body']) + ".png")
		body.set_texture(sprite)
		#brow
		sprite = load(GameData.avatar_sprite.brow + str(avatar['brow']) + ".png")
		brow.set_texture(sprite)
		#ear
		sprite = load(GameData.avatar_sprite.rear + str(avatar['bcolor']) + str(avatar['ear']) + ".png")
		rear.set_texture(sprite)
		sprite = load(GameData.avatar_sprite.lear + str(avatar['bcolor']) + str(avatar['ear']) + ".png")
		lear.set_texture(sprite)
		#eye
		sprite = load(GameData.avatar_sprite.eye + str(avatar['ecolor']) + str(avatar['eye']) + ".png")
		eye.set_texture(sprite)
		#hair
		sprite = load(GameData.avatar_sprite.hair + str(avatar['hcolor']) + str(avatar['hair']) + ".png")
		hair.set_texture(sprite)
		#head
		sprite = load(GameData.avatar_sprite.head + str(avatar['head']) + ".png")
		head.set_texture(sprite)
		#mouth
		sprite = load(GameData.avatar_sprite.mouth + str(avatar['mouth']) + ".png")
		mouth.set_texture(sprite)
		
	if data == "equipment":
		for key in equipment.keys():
			if str(equipment[key]) == "-1":
				var sprite = load(GameData.equipment_sprite.default + "empty_16_11_spritesheet.png")
				if key == "earring":
					rearring.set_texture(sprite)
					learring.set_texture(sprite)
					
				elif key == "glove":
					lglove.set_texture(sprite)
					rglove.set_texture(sprite)
				else:
					sprite_dict[key].set_texture(sprite)

			else:
				if key == "earring":
					var sprite = load(GameData.equipment_sprite[rearring] + str(equipment[key])+".png")
					rleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite[learring] + str(equipment[key])+".png")
					lleg.set_texture(sprite)

				elif key == "glove":
					var sprite = load(GameData.equipment_sprite[rglove] + str(equipment[key])+".png")
					rleg.set_texture(sprite)
					sprite = load(GameData.equipment_sprite[lglove] + str(equipment[key])+".png")
					lleg.set_texture(sprite)

				else:
					var sprite
					if equipment[key] is Dictionary:
						sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+".png")
					else:
						sprite = load(GameData.equipment_sprite[key] + str(equipment[key])+".png")
					sprite_dict[key].set_texture(sprite)

func avatar_check():
	if avatar != Global.player.avatar:
		avatar = Global.player.avatar
		update_avatar(avatar)
	if equipment != Global.player.equipment:
		equipment = Global.player.equipment
		update_avatar(equipment)

# warning-ignore:unused_argument
func change_equipment(equipment_slot, item_id):
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "slash":
		self.get_parent().attacking = false
