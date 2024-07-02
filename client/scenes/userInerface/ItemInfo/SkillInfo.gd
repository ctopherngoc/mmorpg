extends Popup

var skill_id: String

onready var skillName = $Background/MarginContainer/VBoxContainer/Label
onready var description = $Background/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label
onready var skillIcon = $Background/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
#onready var skill_path = "res://assets/skillSprites/"

func _ready() -> void:
	var skill_info = GameData.skill_data[GameData.skill_class_dictionary[skill_id].location[0]][GameData.skill_class_dictionary[skill_id].location[1]]
	skillName.text = str(skill_info.name)
	description.text = str(skill_info.description)
	skillIcon.texture = load(GameData.skill_class_dictionary[skill_id].icon)
