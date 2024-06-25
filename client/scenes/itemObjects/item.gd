extends Node2D
onready var id
onready var item_type
onready var sprite_node = $Sprite
onready var animation_player = $AnimationPlayer
onready var spite_path = {
	"etc": "res://assets/itemSprites/etcItems/",
	"equipment": "res://assets/itemSprites/equipItems/",
	"use": "res://assets/itemSprites/useItems/",}
	
func _ready() -> void:
	"""
	worldstate[item] :  {"P": item.position, "I": item.id}
	"""
	var sprite = load(spite_path[item_type] + str(id) + ".png")
	sprite_node.set_texture(sprite)
	scale()
	animation_player.play("idle")
	
func scale() -> void:
	if item_type == "equipment":
		sprite_node.scale = Vector2(.3,.3)
	elif item_type == "use":
		if "Arrow" in GameData.itemTable[id].itemName:
			sprite_node.scale = Vector2(.3,.3)
		else:
			sprite_node.scale = Vector2(.4,.4)
	else:
		sprite_node.scale = Vector2(.5,.5)
		
