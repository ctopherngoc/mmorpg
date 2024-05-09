extends Node2D
onready var id
onready var item_type
onready var sprite_node = $Sprite
onready var spite_path = {
	"etc": "res://assets/itemSprites/etcItems/",
	"equipment": "res://assets/itemSprites/equipItems/",
	"use": "res://assets/itemSprites/useItems/",
}
func _ready() -> void:
	"""
	worldstate[item] :  {"P": item.position, "I": item.id}
	"""
	var sprite = load(spite_path[item_type] + str(id) + ".png")
	sprite_node.set_texture(sprite)
