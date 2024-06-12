extends Control

var skill_tabs = preload("res://scenes/userInerface/SkillTab.tscn")
var skill_container_instance = preload("res://scenes/userInerface/SkillContainer.tscn")

signal move_to_top

onready var tab_container = $Background/M/V/TabContainer
onready var skill_container = $Background/M/V/TabContainer

onready var skill_tab_ref
onready var skill_tab_data = []
onready var initialize = 0
var drag_position = null

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
	
	# for job tab
	var count = 0
	var tab_count = 0
	while count < 10:
		if str(count) in tabs:
			#print(count)
			# reference to tab order of character
			skill_tab_data.append(count)
			
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
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer/Label").text = GameData.skill_data[tab_count-1][skill_count].name
				skill_container_new.skill_data.id = GameData.skill_data[tab_count-1][skill_count].name
				# get skill level
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Label2").text = str(skill_tab_ref[str(tab_count-1)][str(skill_count)])
				skill_container_new.skill_data.level = skill_tab_ref[str(tab_count-1)][str(skill_count)]
				
				# get skill icon
				# change to tab number and skill id
				if skill_container_new.skill_data.level > 0:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = load("res://assets/skillSprites/0/icon.png")
				else:
					skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = skill_container_new.to_gray_scale(load("res://assets/skillSprites/0/icon.png"))
				# if character ap > 1
				if Global.player.stats.base.ap == 0:
					skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
				skill_tab_new.get_node("ScrollContainer/GridContainer").add_child(skill_container_new)
				skill_count += 1
			tab_container.add_child(skill_tab_new)
		count += 1
			
func update_skills():
	for job in Global.player.skills.keys():
		
		# add into array and create tab
		if not job in skill_tab_data:
			skill_tab_data.append(job)
			
			var skill_tab_new = skill_tabs.instance()
			
			# change tab name
			skill_tab_new.name = skill_tab_data.length() - 1
			var skills_ref = Global.player.skills[job].keys()
			
			var skill_count = 0
			while skill_count < skills_ref.size():
				var skill_container_new = skill_container_instance.instance()
				
				# get skill icon
				# change to tab number and skill id
				skill_container_new.get_node("HBoxContainer/NinePatchRect/Icon").texture = load("res://assets/skillSprites/0/icon.png")
				# get skill name
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer/Label").text = GameData.skill_data[int(job)][skill_count].name
				# get skill level
				skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Label2").text = str(skill_tab_ref[job][str(skill_count)])
				# if character ap > 1
				if Global.player.stats.base.ap == 0:
					skill_container_new.get_node("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
				skill_tab_new.get_node("ScrollContainer/GridContainer").add_child(skill_container_new)
				skill_count += 1
			tab_container.add_child(skill_tab_new)
			
		else:
			for tab in skill_tab_data:
				for skill in GameData.skill_data:
					var update_skill_container = tab_container.get_node("%s/CenterContainer/GridContainer/%s" % [tab, skill])
					if skill_tab_ref[tab][skill].level != int(update_skill_container.skill_level.text):
						update_skill_container.skill_level.text = str(skill_tab_ref[tab][skill].level)
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
