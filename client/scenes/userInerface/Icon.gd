extends CenterContainer
var item_data = {
	"id": null,
	"item": null,
	"q": null,
}

onready var icon = $Icon
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_drag_data(_pos):
	var data = {}
	data["origin_texture"] = icon.texture
	data["item_data"] = item_data
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = icon.texture
	drag_texture.rect_size = Vector2(60, 60)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	
	return data

func can_drop_data(_pos, data):
	return true
	return false

func drop_drata(_pos,data):
	pass
	# send rpc to server to change data in character inventory
	#icon.texture = data["origin_texture"]
	#item_data = data.item_data
	
# create function that gets call from rpc return update slots/inv
"""
Required to add rpc calls to server to swap inventory data.
Server remove func to validate item move request -> 
update server char inventory data -> client remote func to update character data ->
 update inventory window icons (similar to health hud)
"""
