extends Node2D

onready var body = $CompositeSprite/Body
onready var headgear = $CompositeSprite/Headgear
onready var head = $CompositeSprite/Head
onready var hair = $CompositeSprite/Hair
onready var fhair = $CompositeSprite/FHair
onready var eye = $CompositeSprite/Eye
onready var eyewear = $CompositeSprite/Eyewear
onready var face = $CompositeSprite/Face
onready var brow = $CompositeSprite/Brow
onready var ear = $CompositeSprite/Ear
onready var earring = $CompositeSprite/Earring
onready var mouth = $CompositeSprite/Mouth
onready var armor = $CompositeSprite/Armor
onready var underwear = $CompositeSprite/Underwear
onready var shoe = $CompositeSprite/Shoe
onready var glove = $CompositeSprite/Glove
onready var lhand = $CompositeSprite/LHand
onready var rhand = $CompositeSprite/RHand

const composite_sprites = preload("res://scenes/userInerface/CompositeSprite.gd")
var curr_color: int = 0
var curr_body: int = 0
var curr_headgear: int = 0
var curr_head: int = 0
var curr_hair: int = 0
var curr_fhair: int = 0
var curr_eye: int = 0
var curr_eyewear: int = 0
var curr_face: int = 0
var curr_brow: int = 0
var curr_ear: int = 0
var curr_earring: int = 0
var curr_mouth: int = 0
var curr_armor: int = 0
var curr_underwear: int = 0
var curr_shoe: int = 0
var curr_glove: int = 0
var curr_lhand: int = 0
var curr_rhand: int = 0

func _ready():
	body.texture = composite_sprites.body_spritesheet["000"]

func createBodySprite():
	var key = str(curr_body) + str(curr_color) + str(curr_head)
	print(key)
	body.texture = composite_sprites.body_spritesheet[key]

func _on_Body_pressed():
	curr_body = (curr_body + 1) % 2
	createBodySprite()

func _on_Color_pressed():
	curr_color = (curr_color + 1) % 6
	createBodySprite()

func _on_Head_pressed():
	curr_head = (curr_head + 1) % 9
	createBodySprite()
