extends Control

var skill_tabs = preload("res://scenes/userInerface/InGameUI/SkillTab.tscn")
var skill_container_instance = preload("res://scenes/userInerface/InGameUI/SkillContainer.tscn")

signal move_to_top

onready var tab_container = $Background/M/V/TabContainer
onready var skill_container = $Background/M/V/TabContainer
onready var ap_label = $Background/M/V/ColorRect/HBoxContainer/apLabel

onready var skill_tab_ref
onready var skill_tab_data: Array = []
onready var initialize = 0
var drag_position = null
onready var type = "skill"

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_skills", self, "update_skills")
# warning-ignore:return_value_discarded
	Signals.connect("toggle_skills", self, "toggle_skills")
	
	poplulate_skills()

	# scroll through tabs (equip, use, etc) notmade yet
func poplulate_skills():
	# inventory_tabs can be changed to global.player.inventory
	skill_tab_ref = Global.player.skills
	#print(skill_tab_ref)
	var tabs = skill_tab_ref.keys()
	#print("keys: %s" % tabs)
	#print("typeof: %s" % typeof(tabs[0]))
	ap_label.text = str(Global.player.stats.base.ap)
	
	# for job tab
	var count = 0
	var tab_count = 0
	while count < 10:
		if str(count) in tabs:
			#print(count)
			# reference to tab order of character
			skill_tab_data.append(str(count))
			
			# create tab instance
			var skill_tab_new = skill_tabs.instance()
			
			# change tab name
			skill_tab_new.name = str(tab_count)
			var skills_ref = skill_tab_ref[str(tab_count)].keys()
			skills_ref.sort()
			#print("skills_ref: ", skills_ref)
			tab_count += 1
			var skill_count = 0
			
			while skill_count < skills_ref.size():
				var skill_container_new = skill_container_instance.instance()
				
				# get skill name
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer/Label").text = GameData.skill_data[str(tab_count-1)][str(skill_count)].name
				skill_container_new.skill_data.name = GameData.skill_data[str(tab_count-1)][str(skill_count)].name
				# get skill id
				skill_container_new.skill_data.id = GameData.skill_data[str(tab_count-1)][str(skill_count)].id
				
				# get skill level
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Label2").text = str(skill_tab_ref[str(tab_count-1)][str(skill_count)])
				skill_container_new.skill_data.level = skill_tab_ref[str(tab_count-1)][str(skill_count)]
				
				# get skill icon
				# change to tab number and skill id
				if skill_container_new.skill_data.level > 0:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = load(GameData.skill_class_dictionary[skill_container_new.skill_data.id].icon)
				else:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = skill_container_new.to_gray_scale(load(GameData.skill_class_dictionary[skill_container_new.skill_data.id].icon))
				# if character ap > 1
				if Global.player.stats.base.ap == 0 or skill_tab_ref[str(tab_count-1)][str(skill_count)] == GameData.skill_data[str(tab_count-1)][str(skill_count)].maxLevel:
					skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
				skill_tab_new.get_node("ScrollContainer/GridContainer").add_child(skill_container_new, true)
				skill_count += 1
			tab_container.add_child(skill_tab_new, true)
		count += 1
			
func update_skills():
	skill_tab_ref = Global.player.skills
	ap_label.text = str(Global.player.stats.base.ap)
	
	for job in Global.player.skills.keys():
		
		# add into array and create tab
		if not job in skill_tab_data:
			skill_tab_data.append(job)
			
			var skill_tab_new = skill_tabs.instance()
			
			# change tab name
			skill_tab_new.name = str(skill_tab_data.size() - 1)
			var skills_ref = Global.player.skills[job].keys()
			
			var skill_count = 0
			while skill_count < skills_ref.size():
				var skill_container_new = skill_container_instance.instance()
				
				# get skill icon
				# change to tab number and skill id
				if skill_container_new.skill_data.level > 0:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = load(GameData.skill_class_dictionary[skill_container_new.skill_data.id].icon)
				else:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = skill_container_new.to_gray_scale(load(GameData.skill_class_dictionary[skill_container_new.skill_data.id].icon))
					
				# get skill name
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer/Label").text = GameData.skill_data[str(job)][str(skill_count)].name
				# get skill level
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Label2").text = str(skill_tab_ref[str(job)][str(skill_count)])
				
				# if character ap > 1
				if Global.player.stats.base.ap == 0 or skill_tab_ref[str(job)][str(skill_count)] == GameData.skill_data[str(job)][str(skill_count)].maxLevel:
					skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
				skill_tab_new.get_node("ScrollContainer/GridContainer").add_child(skill_container_new)
				skill_count += 1
			tab_container.add_child(skill_tab_new)
			
		else:
			for tab in skill_tab_data:
				for skill in GameData.skill_data[tab]:
						
					var update_skill_container = tab_container.get_node("%s/ScrollContainer/GridContainer/%s" % [tab, skill])
					if skill_tab_ref[tab][skill] != update_skill_container.skill_data.level:
						update_skill_container.skill_data.level =skill_tab_ref[tab][skill]
						update_skill_container.skill_level.text = str(update_skill_container.skill_data.level)
						
						if update_skill_container.skill_data.level > 0:
							update_skill_container.get_node("HBoxContainer/NinePatchRect/Icon").texture = load(GameData.skill_class_dictionary[update_skill_container.skill_data.id].icon)
						
						if Global.player.stats.base.ap == 0 or skill_tab_ref[tab][skill] == GameData.skill_data[tab][skill].maxLevel:
							update_skill_container.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
#		

func _on_Header_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			print("left mouse button")
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position

func toggle_skills():
	self.visible = not self.visible
