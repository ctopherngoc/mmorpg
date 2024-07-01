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


var avatar = null
var equipment = null
func _ready() -> void:
	#avatar = GameData.test_player.avatar
	#equipment = GameData.test_player.equipment
	avatar = Global.player.avatar
	equipment = Global.player.equipment
	update_avatar("avatar")
	update_avatar("equipment")
# warning-ignore:return_value_discarded
	Signals.connect("level_up", self, "play_level_up")
	Signals.connect("update_sprite", self, "avatar_check")

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	#update_avatar("equipment")
	pass
	#avatar_check()
	
# warning-ignore:unused_argument
func update_avatar(data: String) -> void:
	if data == "avatar":
		avatar = Global.player.avatar
		#body
		var sprite = load(GameData.avatar_sprite.body + str(avatar['bcolor']) + str(avatar['body']) + ".png")
		body.set_texture(sprite)
		#arms
		sprite = load(GameData.avatar_sprite.rarm + str(avatar['bcolor']) + ".png")
		rarm.set_texture(sprite)
		sprite = load(GameData.avatar_sprite.larm + str(avatar['bcolor']) + ".png")
		larm.set_texture(sprite)
		# hand
		sprite = load(GameData.avatar_sprite.rhand + str(avatar['bcolor']) + ".png")
		rhand.set_texture(sprite)
		sprite = load(GameData.avatar_sprite.lhand + str(avatar['bcolor']) + ".png")
		lhand.set_texture(sprite)
		# finger
		sprite = load(GameData.avatar_sprite.lfinger + str(avatar['bcolor']) + ".png")
		lfinger.set_texture(sprite)
		# leg
		sprite = load(GameData.avatar_sprite.rleg + str(avatar['bcolor']) + ".png")
		rleg.set_texture(sprite)
		sprite = load(GameData.avatar_sprite.lleg + str(avatar['bcolor']) + ".png")
		lleg.set_texture(sprite)
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
		sprite = load(GameData.avatar_sprite.head + str(avatar['bcolor']) + ".png")
		head.set_texture(sprite)
		#mouth
		sprite = load(GameData.avatar_sprite.mouth + str(avatar['mouth']) + ".png")
		mouth.set_texture(sprite)
		
	if data == "equipment":
		equipment = Global.player.equipment
		for key in equipment.keys():
			if equipment[key] == null:
				var sprite = load(GameData.equipment_sprite.default + "empty_16_11_spritesheet.png")
				if key == "earring":
					rearring.set_texture(sprite)
					learring.set_texture(sprite)
					
				elif key == "glove":
					lglove.set_texture(sprite)
					rglove.set_texture(sprite)
				else:
					if not "ring" in key:
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
					######################################
					var sprite
					if equipment[key] is Dictionary:
						sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+".png")
					else:
						sprite = load(GameData.equipment_sprite[key] + str(equipment[key])+".png")
					sprite_dict[key].set_texture(sprite)
					######################################

func avatar_check() -> void:
		update_avatar("avatar")
		update_avatar("equipment")

# warning-ignore:unused_argument
func change_equipment(equipment_slot, item_id):
	pass

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "slash":
		self.get_parent().attacking = false
		print(self.get_parent().attacking)
	elif anim_name == "update_level":
		print("level up finished")
	elif anim_name == "ready":
		if self.get_parent().attacking == true:
			self.get_parent().attacking = false
			print("ready ", self.get_parent().attacking)

func play_level_up() -> void:
	AudioControl.play_audio("levelUp")
	$AnimationPlayer2.play("level_up")
