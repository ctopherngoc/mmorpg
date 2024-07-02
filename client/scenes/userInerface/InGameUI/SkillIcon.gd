extends TextureRect

onready var type = "skill"
onready var skill_info  = preload("res://scenes/userInerface/ItemInfo/SkillInfo.tscn")
onready var skill_data

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

func skill_info_free():
	for node in self.get_children():
		if "SkillInfo" in node.name:
			node.queue_free()

func _on_Icon_mouse_entered():
	var skill_node = self.get_parent().get_parent().get_parent()
	var skill_tip = skill_info.instance()
	skill_tip.skill_id = skill_data.id
	var skills_origin = get_node("/root/GameWorld/UI/Control/Skills").rect_global_position
	skill_tip.rect_position.x = skills_origin.x - (skill_tip.rect_size.x *  skill_tip.rect_scale.x) + 5
	skill_tip.rect_position.y = skills_origin.y
	add_child(skill_tip)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("SkillInfo"): # and get_node("SkillInfo").valid:
		get_node("SkillInfo").show()

func _on_Icon_mouse_exited():
	skill_info_free()
