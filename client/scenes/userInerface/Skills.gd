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
	Signals.connect("update_inventory", self, "update_skills")
# warning-ignore:return_value_discarded
	Signals.connect("toggle_inventory", self, "toggle_skills")
	poplulate_skills()

	# scroll through tabs (equip, use, etc) notmade yet
func poplulate_skills():
	# inventory_tabs can be changed to global.player.inventory
	skill_tab_ref = Global.player.skills
	var tabs = skill_tab_ref.keys()
	
	# for job tab
	var count = 0
	var tab_count = 0
	while count < 10:
		if count in tabs:
			# reference to tab order of character
			skill_tab_data.append(count)
			
			# create tab instance
			var skill_tab_new = tab_container.instance()
			
			# change tab name
			skill_tab_new.name = tab_count
			var skills_ref = skill_tab_ref[tab_count].keys()
			
			tab_count += 1
			
			var skill_count = 0
			while skill_count < skills_ref.length():
				var skill_container_new = skill_container_instance.instance()
				
				# get skill icon
				# change to tab number and skill id
				skill_container_new.get_child("HBoxContainer/NinePatchRect/Icon").texture = load("res://assets/skillSprites/0/icon.png")
				# get skill name
				skill_container_new.get_child("HBoxContainer/VBoxContainer/HBoxContainer/Label").text = GameData.skill_data[tab_count-1][skill_count].name
				# get skill level
				skill_container_new.get_child("HBoxContainer/VBoxContainer/HBoxContainer2/Label2").text = str(skill_tab_ref[tab_count-1][skill_count])
				# if character ap > 1
				if Global.player.stats.base.ap == 0:
					skill_container_new.get_child("HBoxContainer/VBoxContainer/HBoxContainer2/Button").visible = false
				skill_tab_new.add_child(skill_container_new)
				skill_count += 1
			tab_container.add_child(skill_tab_new)
		count += 1
			
func update_skills():
	# inventory_tabs can be changed to global.player.inventory
	skill_tab_ref = Global.player.skills
	for tab in skill_tab_data:
		for skill in tab:
			var update_skill_container = tab_container.get_node("%s/CenterContainer/GridContainer/%s" % [tab, skill])
			pass
#			if inv_ref[tab][count] != null:
#				# get item node from node_list
#				var item = inv_ref[tab][count]
#				var item_node = node_list[tab][count]
#				#print("in update inventory, item: %s" % item)
#				var _item_name = GameData.itemTable[str(item['id'])]["itemName"]
#				item_node.item_data["id"] = str(item['id'])
#				item_node.item_data["item"] = GameData.itemTable[str(item['id'])]["itemName"]
#				# if stackable exit number on iventory slot
#				if tab in stackable_tabs:
#					item_node.label.text = str(item["q"])
#					item_node.item_data["q"]= item["q"]
#				if tab == "equipment":
#					var temp_item_path = item_path + "equipItems/" + inv_ref[tab][count]["id"] + ".png"
#					item_node.icon.texture = load(temp_item_path)
#				elif tab == "use":
#					var temp_item_path = item_path + "useItems/" + inv_ref[tab][count]["id"] + ".png"
#					item_node.icon.texture = load(temp_item_path)
#				elif tab == "etc":
#					var temp_item_path = item_path + "etcItems/" + inv_ref[tab][count]["id"] + ".png"
#					item_node.icon.texture = load(temp_item_path)
#			else:
#				var item_node = node_list[tab][count]
#				item_node.item_data = {"id": null,"item": null, "q": null}
#				item_node.icon.set_texture(null)

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
			

"""
func update inventory

Required to add rpc calls to server to swap inventory data.
Server remove func to validate item move request -> 
update server char inventory data -> client remote func to update character data ->
 update inventory window icons (similar to health hud)
"""

#func test_setup():
#	inventory_tabs = inv_ref.keys()
#	for key in inventory_tabs:
#		if key != "100000":
#			var count = 0
#			while count < max_slots:
#				inv_ref[key].append(null)
#				count += 1
#	#var inventory_tabs = Global.player.inventory.keys()
#	#var inv_ref = Global.player.inventory
#	inv_ref["use"][0] = {'id': "300001", 'q': 5}
#	inv_ref["use"][1] = {'id': "300002", 'q': 500}
#	inv_ref["use"][6] = {'id': "300003", 'q': 420}
#	inv_ref["equipment"][1] = {'id': "500004"}
#	inv_ref["equipment"][6] = {'id': "500005"}
#	inv_ref["100000"] = 123456789
#
#
#func _on_TabContainer_tab_selected(_tab):
#	AudioControl.play_audio("menuClick")
#
#func toggle_inventory():
#	self.visible = not self.visible
