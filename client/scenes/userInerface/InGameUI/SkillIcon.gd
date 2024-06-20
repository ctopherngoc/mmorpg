extends TextureRect

onready var type = "skill"

func _ready():
	pass

func get_drag_data(_pos):
	#dragging = true
	# if slot is not null
	#if Global.player.inventory[tab][slot_index] != null:
	var skill_node = self.get_parent().get_parent().get_parent()
	if skill_node.skill_data.level != 0:
		var data = {}
		data["origin_node"] = skill_node
		data["origin_texture"] = self.texture
		data["skill_data"] = skill_node.skill_data
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = self.texture
		drag_texture.rect_size = Vector2(50, 50)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data
