extends Node2D

onready var body = $CompositeSprite/Body
onready var head = $CompositeSprite/Head
onready var hair = $CompositeSprite/Hair
onready var eye = $CompositeSprite/Eye
onready var brow = $CompositeSprite/Brow
onready var ear = $CompositeSprite/Ear
onready var mouth = $CompositeSprite/Mouth
onready var outfit = $CompositeSprite/Outfit
onready var lleg = $CompositeSprite/Lleg
onready var rleg = $CompositeSprite/Rleg
onready var larm = $CompositeSprite/Larm
onready var lhand = $CompositeSprite/Lhand
onready var lwep = $CompositeSprite/LWeapon
onready var lfinger = $CompositeSprite/Lfinger
onready var bottom = $CompositeSprite/Bottom
onready var lglove = $CompositeSprite/Lglove
onready var lear = $CompositeSprite/Lear
onready var ammo = $CompositeSprite/Ammo
onready var top = $CompositeSprite/Top
onready var headgear  = $CompositeSprite/Headgear
onready var rear = $CompositeSprite/Rear
onready var rarm = $CompositeSprite/Rarm
onready var rwep = $CompositeSprite/Rweapon
onready var rhand = $CompositeSprite/Rhand
onready var rglove = $CompositeSprite/Rglove

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
