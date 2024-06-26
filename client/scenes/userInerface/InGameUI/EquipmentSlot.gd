extends Control

onready var icon = $Icon
onready var background = $TextureRect
onready var empty_bg = "res://assets/UI/background/inventorySlots2.png"
onready var used_bg = "res://assets/UI/backgroundSource/Green.png"
onready var label = $Label
var dragging = false

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
var slot
var type

func _ready():
	Signals.connect("toggle_inventory", self, "item_info_free")

var item_data = {
	"id" : null,
	"item": null,
}
	
func _notification(what):
	if what == 22:
		item_info_free()

func get_drag_data(_pos):
	# if slot is not null
	#if Global.player.inventory[tab][slot_index] != null:
	if item_data != null:
		dragging = true
		var data = {}
		data["origin_node"] = self
		data["origin_texture"] = icon.texture
		data["item_data"] = item_data
		data["tab"] = "equipment"
		data["slot"] = type
		
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
		if self.type == "rhand":
			print("righthand")
			return true
		elif self.type == "lhand":
			print("lefthand")
			if Global.player.stats.base.job in []:
				print("job in dual wield")
				return true
			else:
				print("job not in dual wield")
				return false
		else:
			print("weapon but not right hand or left hand")
			return false
	elif GameData.equipmentTable[data.item_data.id].type == "shield" and self.type == "lhand":
		print("sheild and left hand")
		return true
	elif GameData.equipmentTable[data.item_data.id].type == self.type:
		print("equipment and slot same type")
		return true
	else:
		print("incorrect slot")
		return false

func drop_data(_pos, data):
	# from inventory to empty equipment slot
	if item_data.id == null:
		# send server request
		Server.send_equipment_request(slot, data.from_slot)
		AudioControl.play_audio("itemSwap")
		
		# setup equipment slot
		item_data.id = data.item.id
		item_data.item = data.item_data
		icon.texture = data.origin_texture
		
		# null out inventory slot
		data.origin_node.texture = null
		data.origin_node.item_data.id = null
		data.origin_node.item_data.item = null
		
	else:
		if data.origin_node == self:
			print("same node")
			return
			
		# temp vars to hold each slots info
		Server.send_equipment_request(slot, data.from_slot)
		var drag_icon = data.item_data
		var drop_icon = item_data
	
		AudioControl.play_audio("itemSwap")
		data.origin_node.dragging = false
		data.origin_node.item_info_free()
		self.item_info_free()
	#	# update beginning slot with destination slot info
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
			#print(item_data)
			if item_data.id:
				AudioControl.play_audio("menuClick")

func _on_0_gui_input(event):
	pass
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed and event.is_doubleclick():
#			#print("double click,use item: %s %s" % [item_data.id, item_data.item])
#			if item_data.id == null:
#				print("empty")
#			elif GameData.itemTable[item_data.id].itemType == "use":
#				#print("use")
#				var q = int(label.text) -1
#				#print(q)
#				label.text = str(q)
#				Server.use_item(item_data.id, slot_index)
#				#print(GameData.itemTable[item_data.id].description)
#			else:
#				pass
#				#print("not use")
#				#print(GameData.itemTable[item_data.id].description)
#		elif event.button_index == BUTTON_LEFT and event.pressed:
#			print("I've been clicked D:")


func _on_0_mouse_entered():
	pass
	
#	if item_data.id == null:
#		pass
#	else:
#		#print(item_data.id)
#		if GameData.itemTable[str(item_data.id)].itemType == "equipment" and tab == "equipment":
#			var equip_tip = equip_info.instance()
#			equip_tip.origin = "Inventory"
#			equip_tip.slot = slot_index
#			equip_tip.tab = tab
#			#var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").get_global_transform_with_canvas().origin
#			var inventory_origin = get_node("/root/GameWorld/UI/Control/Inventory").rect_global_position
#			#equip_tip.rect_position.x = inventory_origin.x - (equip_tip.rect_size.x * equip_tip.rect_scale.x)
#			equip_tip.rect_position.x = inventory_origin.x - (equip_tip.rect_size.x * .72)
#			#print((equip_tip.rect_size.x * .7))
#			equip_tip.rect_position.y = inventory_origin.y
#			add_child(equip_tip)
#			yield(get_tree().create_timer(0.35), "timeout")
#			if has_node("ItemInfo") and get_node("ItemInfo").valid:
#				#print("Show equipinfo")
#				get_node("ItemInfo").show()
#		else:
#			#item_info
#			var item_tip = item_info.instance()
#			item_tip.origin = "Inventory"
#			item_tip.slot = slot_index
#			item_tip.tab = tab
#			#var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").get_global_transform_with_canvas().origin
#			var inventory_origin = get_node("/root/GameWorld/UI/Control/Inventory").rect_global_position
#			item_tip.rect_position.x = inventory_origin.x - (item_tip.rect_size.x * item_tip.rect_scale.x)
#			item_tip.rect_position.y = inventory_origin.y
#			add_child(item_tip)
#			yield(get_tree().create_timer(0.35), "timeout")
#			if has_node("ItemInfo") and get_node("ItemInfo").valid:
#				#print("Show item_tip")
#				get_node("ItemInfo").show()


func _on_0_mouse_exited():
	#print("mouse exit %s" % item_data.id)
	while dragging:
		return
	if item_data == null:
		pass
#	elif GameData.itemTable[str(item_data.id)].itemType == "equipment":
#		#print("equipment tip queue_free")
#		get_node("EquipInfo").free()
#	else:
	item_info_free()
	#print("mouse exited item slot")
	
func item_info_free():
	for node in self.get_children():
		if "ItemInfo" in node.name:
			node.queue_free()
