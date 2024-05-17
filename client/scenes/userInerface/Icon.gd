extends CenterContainer
onready var tab
onready var slot_index

onready var equip_info = preload("res://scenes/userInerface/ItemInfo/EquipInfo.tscn")
onready var item_info = preload("res://scenes/userInerface/ItemInfo/ItemInfo.tscn")

var tab_dict = {"equipment": 0, "use": 1, "etc": 2}

var item_data = {
	"id": null,
	"item": null,
	"q": null,
}

onready var icon = $Icon
onready var label = $VBoxContainer/Label
var dragging = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
		
		return data

func can_drop_data(_pos, data):
	# check if we can drop item into slow
	# if slot is null -> move item
	if item_data.id == null:
		return true
	else:
		if data.tab == tab:
			return true
		else:
			return false

func drop_data(_pos,data):
	# temp vars to hold each slots info
	var drag_icon = data.item_data
	var drop_icon = item_data
	
	"""
	tab: 0 = equip, 1 = use, 2 = etc
	from: 0-31 (slot)
	to: 0-31(slot)
	"""
	Server.send_inventory_movement(tab_dict[tab], data["from_slot"], slot_index)
	AudioControl.play_audio("itemSwap")
	
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
	data.origin_node.dragging = false
	data.origin_node.item_info_free()
	
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
			#print("double click,use item: %s %s" % [item_data.id, item_data.item])
			if item_data.id == null:
				print("empty")
			elif GameData.itemTable[item_data.id].itemType == "use":
				#print("use")
				var q = int(label.text) -1
				print(q)
				label.text = str(q)
				Server.use_item(item_data.id, slot_index)
				print(GameData.itemTable[item_data.id].description)
			else:
				pass
				#print("not use")
				#print(GameData.itemTable[item_data.id].description)
#		elif event.button_index == BUTTON_LEFT and event.pressed:
#			print("I've been clicked D:")


func _on_0_mouse_entered():
	if item_data.id == null:
		pass
	else:
		#print(item_data.id)
		if GameData.itemTable[str(item_data.id)].itemType == "equipment" and tab == "equipment":
			var equip_tip = equip_info.instance()
			equip_tip.origin = "Inventory"
			equip_tip.slot = slot_index
			equip_tip.tab = tab
			#var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").get_global_transform_with_canvas().origin
			var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").rect_global_position
			equip_tip.rect_position.x = inventory_origin.x - (equip_tip.rect_size.x) + 100
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
			var inventory_origin = get_node("/root/currentScene/UI/Control/Inventory").rect_global_position
			item_tip.rect_position.x = inventory_origin.x - (item_tip.rect_size.x) + 100
			item_tip.rect_position.y = inventory_origin.y
			add_child(item_tip)
			yield(get_tree().create_timer(0.35), "timeout")
			if has_node("ItemInfo") and get_node("ItemInfo").valid:
				#print("Show item_tip")
				get_node("ItemInfo").show()


func _on_0_mouse_exited():
	#print("mouse exit %s" % item_data.id)
	while dragging:
		return
	if item_data.id == null:
		pass
#	elif GameData.itemTable[str(item_data.id)].itemType == "equipment":
#		#print("equipment tip queue_free")
#		get_node("EquipInfo").free()
#	else:
	if get_node_or_null("ItemInfo"):
		get_node("ItemInfo").free()
	
func item_info_free():
	if get_node_or_null("ItemInfo"):
		get_node("ItemInfo").free()
