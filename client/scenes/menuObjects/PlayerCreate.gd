extends Node2D

onready var body = $CompositeSprite/Body
onready var head = $CompositeSprite/Head
onready var hair = $CompositeSprite/Hair
onready var eye = $CompositeSprite/Eye
onready var brow = $CompositeSprite/Brow
onready var ear = $CompositeSprite/Ear
onready var mouth = $CompositeSprite/Mouth
onready var outfit = $CompositeSprite/Outfit


const composite_sprites = preload("res://scenes/menuObjects/CompositeSprite.gd")
var curr_bcolor: int = 0
var curr_body: int = 0
var curr_head: int = 0
var curr_hair: int = 0
var curr_hcolor: int = 0
var curr_chair: int = 0
var curr_eye: int = 0
var curr_ecolor: int = 0
var curr_face: int = 0
var curr_brow: int = 0
var curr_ear: int = 0
var curr_mouth: int = 0
var curr_outfit: int = 0

"""
var curr_lhand: int = 0
var curr_hgear: int = 0
var curr_fhair: int = 0
var curr_eyewear: int = 0
var curr_earring: int = 0
var curr_glove: int = 0
var curr_rhand: int = 0
var bottom: int = 0
"""

func _ready():
	body.texture = composite_sprites.body_spritesheet["00"]
	head.texture = composite_sprites.head_spritesheet["00"]
	outfit.texture = composite_sprites.outfit_spritesheet["0"]
	brow.texture = composite_sprites.brow_spritesheet["0"]
	hair.texture = composite_sprites.hair_spritesheet["00"]
	eye.texture = composite_sprites.eye_spritesheet["00"]
	ear.texture = composite_sprites.ear_spritesheet["00"]

func compile_char_data():
	var data = {
	"bc" : curr_bcolor,
	"b": curr_body,
	"he": curr_head,
	"hc": curr_hcolor,
	"h": curr_hair,
	"e": curr_eye,
	"ec": curr_ecolor,
	"m": curr_mouth,
	"ea": curr_ear,
	"o": curr_outfit,
	"br": curr_brow,
	}
	return data

func createSprite(part):
	if part == "body":
		var key = str(curr_bcolor) + str(curr_body)
		body.texture = composite_sprites.body_spritesheet[key]
		
	elif part == "head":
		var key = str(curr_bcolor)+ str(curr_head)
		head.texture = composite_sprites.head_spritesheet[key]
	
	# body head ears
	elif part =="bcolor":
		var key = str(curr_bcolor) + str(curr_body)
		body.texture = composite_sprites.body_spritesheet[key]
		
		var key2 = str(curr_bcolor)+ str(curr_head)
		head.texture = composite_sprites.head_spritesheet[key2]
		
		var key3 = str(curr_bcolor) + str(curr_ear)
		ear.texture = composite_sprites.ear_spritesheet[key3]
		
	elif part == "hair":
		var key = str(curr_hcolor) + str(curr_hair)
		hair.texture = composite_sprites.hair_spritesheet[key]
		
	elif part == "eye":
		var key = str(curr_ecolor)+ str(curr_eye)
		eye.texture = composite_sprites.eye_spritesheet[key]
		
	elif part == "brow":
		var key = str(curr_brow)
		brow.texture = composite_sprites.brow_spritesheet[key]
		
	elif part == "mouth":
		var key = str(curr_mouth)
		mouth.texture = composite_sprites.mouth_spritesheet[key]
		
	elif part == "ear":
		var key = str(curr_bcolor) + str(curr_ear)
		ear.texture = composite_sprites.ear_spritesheet[key]
		
	elif part == "outfit":
		var key = str(curr_outfit)
		outfit.texture = composite_sprites.outfit_spritesheet[key]
	
	

func _on_Body_pressed():
	curr_body = (curr_body + 1) % 2
	createSprite("body")

# effects body, head, ears
func _on_BColor_pressed():
	curr_bcolor = (curr_bcolor + 1) % 6
	createSprite("bcolor")

func _on_Head_pressed():
	curr_head = (curr_head + 1) % 8
	createSprite("head")

func _on_Hair_pressed():
	curr_hair = (curr_hair + 1) % 4
	createSprite("hair")

func _on_HColor_pressed():
	curr_hcolor = (curr_hcolor + 1) % 4
	createSprite("hair")

func _on_Eyes_pressed():
	curr_eye = (curr_eye + 1) % 3
	createSprite("eye")

func _on_EColor_pressed():
	curr_ecolor = (curr_ecolor + 1) % 3
	createSprite("eye")

func _on_Ears_pressed():
	curr_ear = (curr_ear + 1) % 2
	createSprite("ear")

func _on_Mouth_pressed():
	curr_mouth = (curr_mouth + 1) % 3
	createSprite("mouth")

func _on_Brow_pressed():
	curr_brow = (curr_brow + 1) % 4
	createSprite("brow")

func _on_Outfit_pressed():
	curr_outfit = (curr_outfit + 1) % 3
	createSprite("outfit")
