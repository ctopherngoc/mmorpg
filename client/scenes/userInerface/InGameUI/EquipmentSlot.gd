extends Control

onready var icon = $Icon
onready var background = $TextureRect
onready var empty_bg = "res://assets/UI/background/inventorySlots2.png"
onready var used_bg = "res://assets/UI/backgroundSource/Green.png"
onready var equip_info = preload("res://scenes/userInerface/ItemInfo/EquipInfo.tscn")
onready var label = $Label
var dragging = false
var slot
#var type
"""
	slot :  type
	"faceacc": "face",
	"headgear": "head",
	"earring": "earring",
	"ammo": "ammo",
	"top": "top",
	"glove": "glove",
	"lweapon": "lhand",
	"bottom": "bottom",
	"rweapon": "rhand",
	"eyeacc": "eye",
	"tattoo": "tattoo",
	"pocket": "pocket",
	"ring1":"ring",
	"ring2": "ring",
	"ring3": "ring",
"""


func _ready():
	Signals.connect("toggle_equipment", self, "item_info_free")

var item_data = {
	"id" : null,
	"item": null,
}
	
func _notification(what):
	if what == 22:
		item_info_free()

func get_drag_data(_pos):
	print("item_data")
	print(item_data)
	# if slot is not null
	#if Global.player.inventory[tab][slot_index] != null:
	if item_data != null:
		dragging = true
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["item_data"] = item_data.duplicate(true)
		data["tab"] = "equipment"
		data["slot"] = slot
		
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
	## INVENTORY TYPE CHECK##
	if not data.tab == "equipment":
		print("not equipment tab")
		return false
	## JOB CHECK ###
	if not GameData.equipmentTable[data.item_data.id].job == null and not GameData.equipmentTable[data.item_data.id].job == Global.player.stats.base.job:
		print("wrong job")
		return false
	## LEVEL CHECK ###
	if not GameData.equipmentTable[data.item_data.id].reqLevel <= Global.player.stats.base.level:
		print("wrong level")
		return false
	## STAT CHECK ###
	if item_data.id:
		print("equipment slot check stats")
		print(item_data)
		if not GameData.equipmentTable[data.item_data.id].reqStr <= Global.player.stats.base.strength + Global.player.stats.buff.strength + Global.player.stats.equipment.strength - item_data.item.strength:
			print("not enough str")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqWis <= Global.player.stats.base.wisdom + Global.player.stats.buff.wisdom + Global.player.stats.equipment.wisdom - item_data.item.wisdom:
			print("not enough wis")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqLuk <= Global.player.stats.base.luck + Global.player.stats.buff.luck + Global.player.stats.equipment.luck - item_data.item.luck:
			print("not enough luk")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqDex <= Global.player.stats.base.dexterity + Global.player.stats.buff.dexterity + Global.player.stats.equipment.dexterity - item_data.item.dexterity:
			print("not enough dex")
			return false
	## STAT CHECK ###
	else:
		print("equipment slot check no equipment")
		if not GameData.equipmentTable[data.item_data.id].reqStr <= Global.player.stats.base.strength + Global.player.stats.buff.strength + Global.player.stats.equipment.strength:
			print("not enough str")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqWis <= Global.player.stats.base.wisdom + Global.player.stats.buff.wisdom + Global.player.stats.equipment.wisdom:
			print("not enough wis")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqLuk <= Global.player.stats.base.luck + Global.player.stats.buff.luck + Global.player.stats.equipment.luck:
			print("not enough luk")
			return false
		if not GameData.equipmentTable[data.item_data.id].reqDex <= Global.player.stats.base.dexterity + Global.player.stats.buff.dexterity + Global.player.stats.equipment.dexterity:
			print("not enough dex")
			return false
	## TYPE CHECK ###
	# if weapon right hand true
	print("pass equipment stat check")
	if GameData.equipmentTable[data.item_data.id].type == "weapon":
		print("checking weapon")
		if self.slot == "rweapon":
			print("rweapon")
			return true
		elif self.slot == "lweapon":
			print("lweapon")
			if Global.player.stats.base.job in []:
				print("job in dual wield")
				return true
			else:
				print("job not in dual wield")
				return false
		else:
			print("weapon but not right hand or left hand")
			return false
	elif GameData.equipmentTable[data.item_data.id].type == "shield" and self.slot == "lhand":
		print("sheild and left hand")
		return true
	elif GameData.equipmentTable[data.item_data.id].type == self.slot:
		print("equipment and slot same type")
		return true
	else:
		print("incorrect slot")
		return false

func drop_data(_pos, data):
	var drag_icon = data.item_data
	var drop_icon = item_data
	
	# from inventory to empty equipment slot
	if item_data.id == null:
		# send server request
		Server.send_equipment_request(slot, data.from_slot)
		AudioControl.play_audio("itemSwap")

		# update beginning slot with destination slot info
		data.origin_node.icon.texture = null
		data.origin_node.item_data = drop_icon
		# update distination slot with beginning slot info
		icon.texture = data["origin_texture"]
		item_data = drag_icon

	else:
		if data.origin_node == self:
			print("same node")
			return

		# temp vars to hold each slots info
		Server.send_equipment_request(slot, data.from_slot)
	
		AudioControl.play_audio("itemSwap")
		data.origin_node.dragging = false
		data.origin_node.item_info_free()
		self.item_info_free()
			
		# update beginning slot with destination slot info
		data.origin_node.icon.texture = icon.texture
		data.origin_node.item_data = drop_icon
		# update distination slot with beginning slot info
		icon.texture = data["origin_texture"]
		item_data = drag_icon
"""
Required to add rpc calls to server to swap inventory data.
Server remove func to validate item move request -> 
update server char inventory data -> client remote func to update character data ->
 update inventory window icons (similar to health hud)
"""
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:

			if item_data.id:
				AudioControl.play_audio("menuClick")

func _on_0_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and event.is_doubleclick():
			if item_data.id == null:
				print("empty")
			else:
				print("trying to unequip %s" % slot)
				var empty_slot = inventory_room_check()
				if empty_slot:
					Server.remove_equipment_request(self.slot, empty_slot)
				else:
					print("equipment %s been clicked D:" % slot)
		elif event.button_index == BUTTON_LEFT and event.pressed:
			print("equipment %s been clicked D:" % slot)

func _on_0_mouse_entered():
	if item_data.id == null:
		print(slot)
	else:
		print("populate equipment window")
		var equip_tip = equip_info.instance()
		equip_tip.origin = "Equipment"
		equip_tip.tab = slot
		var inventory_origin = get_node("/root/GameWorld/UI/Control/Equipment")
		equip_tip.rect_position.x = inventory_origin.rect_global_position.x + (inventory_origin.rect_size.x * inventory_origin.rect_scale.x)
		equip_tip.rect_position.y = inventory_origin.rect_global_position.y
		add_child(equip_tip)
		yield(get_tree().create_timer(0.35), "timeout")
		if has_node("ItemInfo") and get_node("ItemInfo").valid:
			#print("Show equipinfo")
			get_node("ItemInfo").show()

func inventory_room_check():
	var count = 0
	for inventory_slot in Global.player.inventory.equipment:
		if inventory_slot == null:
			return count
		else:
			count += 1
	return null

func _on_0_mouse_exited():
	while dragging:
		return
	if item_data == null:
		pass
	item_info_free()

func item_info_free():
	for node in self.get_children():
		if "ItemInfo" in node.name:
			node.queue_free()

