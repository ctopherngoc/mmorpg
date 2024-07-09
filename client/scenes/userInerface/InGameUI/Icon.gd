extends CenterContainer
onready var tab
onready var slot_index
onready var type = "inventory"
onready var equip_info = preload("res://scenes/userInerface/ItemInfo/EquipInfo.tscn")
onready var item_info = preload("res://scenes/userInerface/ItemInfo/ItemInfo.tscn")
var tab_dict = {"equipment": 0, "use": 1, "etc": 2}

var item_data = {
	"id":  null,
	"item": null,
}

onready var item_info_child_list: Array

onready var icon = $Icon
onready var label = $VBoxContainer/Label
var dragging = false
# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("toggle_inventory", self, "item_info_free")
	
func _notification(what):
	if what == 22:
		item_info_free()

func get_drag_data(_pos):
	dragging = true
	# if slot is not null
	#if Global.player.inventory[tab][slot_index] != null:
	if item_data.id != null:
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["item_data"] = item_data
		data["from_slot"] = slot_index
		data["tab"] = tab
	
	
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = icon.texture
		drag_texture.rect_size = Vector2(60, 60)
		
		var control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		print(data)
		return data

func can_drop_data(_pos, data):
	if data.has("slot"):
		if tab == "equipment":
			# slot empty
			if item_data.id == null:
				print("inventory slot is empty")
				return true
			else:
				print(item_data)
				print(data.item_data)
				if GameData.equipmentTable[item_data.id].type == GameData.equipmentTable[data.item_data.id].type:
					print("slot is occupied with same type")
					if equipment_check(data):
						print("slot can swap")
						return true
					else:
						print("slot cant swap")
						return false
				else:
					print("slot and equip not the same type")
					return false
		else:
			print("equipment -> into non equip tab")
			return false
	else:	
	# check if we can drop item into slow
	# if slot is null -> move item
		if item_data.id == null:
			return true
		else:
			if data.tab == tab:
				#data['origin_node'].get_node("ItemInfo").free()
				return true
			else:
				#data['origin_node'].get_node("ItemInfo").free()
				return false

func drop_data(_pos,data):
	# temp vars to hold each slots info
	var drag_icon = data.item_data
	var drop_icon = item_data
	if data.has("slot"):
		if item_data.id == null:
			# send server request
			Server.remove_equipment_request(data.slot, slot_index)
			AudioControl.play_audio("itemSwap")
			
			# update beginning slot with destination slot info
			data.origin_node.icon.texture = null
			data.origin_node.item_data = drop_icon
			# update distination slot with beginning slot info
			icon.texture = data["origin_texture"]
			item_data = drag_icon
		else:
			# temp vars to hold each slots info
			Server.send_equipment_request(data.slot, slot_index)

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
	else:
		"""
		tab: 0 = equip, 1 = use, 2 = etc
		from: 0-31 (slot)
		to: 0-31(slot)
		"""
		Server.send_inventory_movement(tab_dict[tab], data["from_slot"], slot_index)
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
		
		# if both are equips end function
		if tab == "equipment" and data["tab"] == "equipment":
			return
		
		# update beginning slot if destination slot q is null or not 
		if data.origin_node.item_data.q != null:
			data.origin_node.label.text = str(data.origin_node.item_data.q)
		else:
			data.origin_node.label.text = ""
		
		# update destination slot if beginning slot q is null or not
		if item_data.q != null:
			label.text = str(item_data.q)
		else:
			label.text = ""
			#slot has null
	
# create function that gets call from rpc return update slots/inv
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
			elif GameData.itemTable[item_data.id].itemType == "use":
				var q = int(label.text) -1
				label.text = str(q)
				Server.use_item(item_data.id, slot_index)
			elif GameData.itemTable[item_data.id].itemType == "equipment":
				if GameData.equipmentTable[item_data.id].type == "weapon":
					Server.send_equipment_request("rweapon", slot_index)
				elif GameData.equipmentTable[item_data.id].type == "shield":
					Server.send_equipment_request("lweapon", slot_index)
				else:
					Server.send_equipment_request(GameData.equipmentTable[item_data.id].type, slot_index)
			else:
				pass

func _on_0_mouse_entered():
	if item_data.id == null:
		pass
	else:
		if GameData.itemTable[str(item_data.id)].itemType == "equipment" and tab == "equipment":
			var equip_tip = equip_info.instance()
			equip_tip.origin = "Inventory"
			equip_tip.slot = slot_index
			equip_tip.tab = tab
			var inventory_origin = get_node("/root/GameWorld/UI/Control/Inventory").rect_global_position
			equip_tip.rect_position.x = inventory_origin.x - (equip_tip.rect_size.x *  equip_tip.rect_scale.x) + 5
			equip_tip.rect_position.y = inventory_origin.y
			add_child(equip_tip)
			yield(get_tree().create_timer(0.35), "timeout")
			if has_node("ItemInfo") and get_node("ItemInfo").valid:
				#print("Show equipinfo")
				get_node("ItemInfo").show()
		else:
			#item_info
			var item_tip = item_info.instance()
			item_tip.origin = "Inventory"
			item_tip.slot = slot_index
			item_tip.tab = tab
			#var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").get_global_transform_with_canvas().origin
			var inventory_origin = get_node("/root/GameWorld/UI/Control/Inventory").rect_global_position
			item_tip.rect_position.x = inventory_origin.x - (item_tip.rect_size.x * item_tip.rect_scale.x) + 5
			item_tip.rect_position.y = inventory_origin.y
			add_child(item_tip)
			yield(get_tree().create_timer(0.35), "timeout")
			if has_node("ItemInfo") and get_node("ItemInfo").valid:
				#print("Show item_tip")
				get_node("ItemInfo").show()

func _on_0_mouse_exited():
	while dragging:
		return
	if item_data.id == null:
		pass
	item_info_free()

	
func item_info_free():
	for node in self.get_children():
		if "ItemInfo" in node.name:
			node.queue_free()
		if "EquipInfo" in node.name:
			node.queue_free()
		

# checking of item in inventory slot matches the slot equipped is dragging from
func equipment_check(data) -> bool:
	## INVENTORY TYPE CHECK##
	if not tab == "equipment":
		return false
	## JOB CHECK ###
	if item_data.item.job == 0 or not item_data.item.job == Global.player.stats.base.job:
		return false
	## LEVEL CHECK ###
	if not GameData.equipmentTable[item_data.item.id].reqLevel <= Global.player.stats.base.level:
		return false
	## STAT CHECK ###
	if not GameData.equipmentTable[item_data.item.id].reqStr <= Global.player.stats.base.strength + Global.player.stats.buff.strength + Global.player.stats.equipment.strength - data.item_data.strength:
		return false
	if not GameData.equipmentTable[item_data.item.id].reqWis <= Global.player.stats.base.wisdom + Global.player.stats.buff.wisdom + Global.player.stats.equipment.wisdom - data.item_data.wisdom:
		return false
	if not GameData.equipmentTable[item_data.item.id].reqLuk <= Global.player.stats.base.luck + Global.player.stats.buff.luck + Global.player.stats.equipment.luck - data.item_data.luck:
		return false
	if not GameData.equipmentTable[item_data.item.id].reqDex <= Global.player.stats.base.dexterity + Global.player.stats.buff.dexterity + Global.player.stats.equipment.dexterity - data.item_data.dexterity:
		return false
	## TYPE CHECK ###
	# if weapon right hand true
###################################################################################
#wop: inside inventory weapons checking if it can fit as shield, rweapon or lweapon without equipment slot typing
	if GameData.equipmentTable[item_data.id].type == "weapon":
		if data.slot == "rweapon":
			return true
		elif data.slot == "lweapon":
			if Global.player.stats.base.job in []:
				return true
			else:
				return false
		else:
			return false
	elif GameData.equipmentTable[data.item_data.id][type] == "shield" and data.slot == "lweapon":
		return true
	elif data.item_data.type == item_data.item.type:
		return true
	else:
		return false
		###################################################################################
