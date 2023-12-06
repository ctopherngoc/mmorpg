extends Node2D

onready var body = $Body
onready var head = $Head
onready var hair = $Hair
onready var eye = $Eye
onready var brow = $Brow
onready var ear = $Ear
onready var mouth = $Mouth
onready var outfit = $Outfit
onready var lleg = $Lleg
onready var rleg = $Rleg
onready var larm = $Larm
onready var lhand = $Lhand
onready var lwep = $LWeapon
onready var lfinger = $Lfinger
onready var bottom = $Bottom
onready var lglove = $Lglove
onready var lear = $Lear
onready var ammo = $Ammo
onready var top = $Top
onready var headgear  = $Headgear
onready var rear = $Rear
onready var rarm = $Rarm
onready var rwep = $Rweapon
onready var rhand = $Rhand
onready var rglove = $Rglove
onready var rearring = $Rear/Earring
onready var learring = $Lear/Earring
onready var tattoo = $Tattoo
onready var eyeacc = $Eyeacc
onready var faceacc = $Faceacc

var avatar = null
var equipment = null
func _ready():
	avatar_check()

func _physics_process(delta):
	avatar_check()
	
func update_avatar(data):
	pass

func avatar_check():
	if avatar != Global.player.avatar:
		avatar = Global.player.avatar
		update_avatar(avatar)
	if equipment != Global.player.equipment:
		equipment = Global.player.equipment
		update_avatar(equipment)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "slash":
		self.get_parent().attacking = false
