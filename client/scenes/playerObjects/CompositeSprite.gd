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

onready var test_player = {
	"avatar": {
		"head": "0",
		"ear": "0",
		"ecolor": "0",
		"eye": "0",
		"bcolor": "0",
		"brow": "0",
		"mouth": "0",
		"hair": "0",
		"body": "0",
		"hcolor": "0"
	},
	"equipment": {
		"eyeacc": {"id": "800000"},
		"faceacc": {"id": "800001"},
		"bottom": {
			"maxHealth": 0,
			"strength": 0,
			"critRate": 0,
			"reqLuk": 0,
			"damagePercent": 0,
			"id": "500001",
			"avoidability": 0,
			"jumpSpeed": 0,
			"maxMana": 0,
			"reqStr": 0,
			"uniqueID": "178131510",
			"reqLevel": 0,
			"reqDex": 0,
			"bossPercent": 0,
			"type": "bottom",
			"attack": 0,
			"wisdom": 0,
			"magic": 0,
			"magicDefense": 4,
			"attackSpeed": 0,
			"dexterity": 0,
			"owner": "2043760018",
			"slot": 7,
			"job": 0,
			"accuracy": 0,
			"defense": 13,
			"name": "Cloth Bottom",
			"reqWis": 0,
			"movementSpeed": 0,
			"luck": 0
		},
		"ring3": null,
		"headgear": {"id": "500006"},
		"glove": {"id": "599999"
		},
		"lweapon": null,
		"ammo": null,
		"pocket": null,
		"earring": {"id": "599998"},
		"ring2": null,
		"top": {
			"accuracy": 0,
			"magicDefense": 5,
			"name": "Leather Shirt",
			"id": "500002",
			"maxHealth": 0,
			"defense": 0,
			"job": 0,
			"strength": 0,
			"owner": "1607981857",
			"jumpSpeed": 0,
			"movementSpeed": 0,
			"maxMana": 0,
			"avoidability": 0,
			"reqDex": 0,
			"attack": 0,
			"attackSpeed": 0,
			"reqWis": 0,
			"slot": 7,
			"magic": 0,
			"bossPercent": 0,
			"reqStr": 0,
			"reqLuk": 0,
			"wisdom": 0,
			"reqLevel": 0,
			"type": "top",
			"damagePercent": 0,
			"dexterity": 0,
			"critRate": 0,
			"uniqueID": "83860237",
			"luck": 0
		},
		"tattoo": {"id": "800002"},
		"ring1": null,
		"rweapon": {
			"type": "weapon",
			"jumpSpeed": 0,
			"name": "Training Dagger",
			"magic": 0,
			"maxMana": 0,
			"reqLevel": "0",
			"movementSpeed": 0,
			"id": "200001",
			"bossPercent": 5,
			"attack": 15,
			"reqWis": "0",
			"dexterity": 4,
			"critRate": 0,
			"maxHealth": 0,
			"magicDefense": 0,
			"slot": 7,
			"wisdom": 5,
			"attackSpeed": 5,
			"strength": 5,
			"reqDex": "0",
			"luck": 5,
			"defense": 0,
			"reqStr": "0",
			"damagePercent": 0,
			"job": 0,
			"uniqueID": "161026590",
			"reqLuk": "0",
			"avoidability": 0,
			"weaponType": "dagger",
			"accuracy": 0
		}
	}
}
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

var avatar = null
var equipment = null

var test = true
func _ready() -> void:
	#avatar = GameData.test_player.avatar
	#equipment = GameData.test_player.equipment
	if test:
		avatar = test_player.avatar
		equipment = test_player.equipment
		self.position = Vector2(500,500)
	else:		
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
#	var file = File.new()
#	file.open("user://character.json", file.WRITE)
#	var json_data = { "avatar" : avatar,
#		"equipment": equipment,}
#	file.store_line(JSON.print(json_data, "\t"))
#	file.close()

	if data == "avatar":
		if !test:
			avatar = Global.player.avatar
		#body
		var sprite = load(GameData.avatar_sprite.body + str(avatar['bcolor']) + str(avatar['body']) + ".png")
		body.set_texture(sprite)
		sprite = load(GameData.climb_sprite.body + str(avatar['bcolor']) + str(avatar['body']) + "c.png")
		climb_body.set_texture(sprite)
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
		sprite = load(GameData.climb_sprite.ear + str(avatar['bcolor']) + str(avatar['ear']) + ".png")
		climb_ears.set_texture(sprite)
		#eye
		sprite = load(GameData.avatar_sprite.eye + str(avatar['ecolor']) + str(avatar['eye']) + ".png")
		eye.set_texture(sprite)
		#hair
		sprite = load(GameData.avatar_sprite.hair + str(avatar['hcolor']) + str(avatar['hair']) + ".png")
		hair.set_texture(sprite)
		sprite = load(GameData.climb_sprite.hair + str(avatar['hcolor']) + str(avatar['hair']) + "c.png")
		climb_hair.set_texture(sprite)
		#head
		sprite = load(GameData.avatar_sprite.head + str(avatar['bcolor']) + ".png")
		head.set_texture(sprite)
		#mouth
		sprite = load(GameData.avatar_sprite.mouth + str(avatar['mouth']) + ".png")
		mouth.set_texture(sprite)
		
	if data == "equipment":
		if !test:
			equipment = Global.player.equipment
		var empty_sprite = load(GameData.equipment_sprite.default + "empty_16_11_spritesheet.png")
		var empty_sprite2 = load(GameData.equipment_sprite.default + "empty_16_1_spritesheet.png")
		for key in equipment.keys():
			if equipment[key] == null:
				
				if key == "earring":
					rearring.set_texture(empty_sprite)
					learring.set_texture(empty_sprite)
					climb_earrings.set_texture(empty_sprite2)
					
				elif key == "glove":
					lglove.set_texture(empty_sprite)
					rglove.set_texture(empty_sprite)
					climb_gloves.set_texture(empty_sprite2)
				else:
					if not "ring" in key:
						sprite_dict[key].set_texture(empty_sprite)
						
					
					if key in ["headgear", "top", "bottom"]:
						if key == "headgear":
							climb_sprite_dict[key].set_texture(empty_sprite2)
						elif key == "top":
							climb_sprite_dict[key].set_texture(empty_sprite2)
						elif key == "bottom":
							climb_sprite_dict[key].set_texture(empty_sprite2)

			else:
				if key in ["earring", "glove"]:
					if key == "earring":
						var sprite = load(GameData.equipment_sprite.earring + str(equipment[key].id)+"r.png")
						rearring.set_texture(sprite)
						sprite = load(GameData.equipment_sprite.earring + str(equipment[key].id)+"l.png")
						learring.set_texture(sprite)
						sprite = load(GameData.equipment_sprite.earring + str(equipment[key].id)+"c.png")
						climb_earrings.set_texture(sprite)

					elif key == "glove":
						var sprite = load(GameData.equipment_sprite.glove + str(equipment[key].id)+"r.png")
						rglove.set_texture(sprite)
						sprite = load(GameData.equipment_sprite.glove + str(equipment[key].id)+"l.png")
						lglove.set_texture(sprite)
						sprite = load(GameData.equipment_sprite.glove + str(equipment[key].id)+"c.png")
						climb_gloves.set_texture(sprite)

				else:
					# every equips is dictionary or null
					######################################
					var sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+".png")
					sprite_dict[key].set_texture(sprite)
					if key in ["headgear", "top", "bottom"]:
						if key == "headgear":
							if equipment[key]["id"] in GameData.full_headgear_list:
					
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

							sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+"c.png")
							climb_sprite_dict[key].set_texture(sprite)
						elif key == "top":
							sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+"c.png")
							climb_sprite_dict[key].set_texture(sprite)
						elif key == "bottom":
							sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+"c.png")
							climb_sprite_dict[key].set_texture(sprite)

					# old
					######################################					######################################
#					var sprite
#					if equipment[key] is Dictionary:
#						sprite = load(GameData.equipment_sprite[key] + str(equipment[key]["id"])+".png")
#					else:
#						sprite = load(GameData.equipment_sprite[key] + str(equipment[key])+".png")
#					sprite_dict[key].set_texture(sprite)
					
					######################################
					# situation for climbing, top, bottom, helmet

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

func set_climb() -> void:
	normal.visible = false
	climb_sprite.visible = true

func unset_climb() -> void:
	normal.visible = true
	climb_sprite.visible = false
	
