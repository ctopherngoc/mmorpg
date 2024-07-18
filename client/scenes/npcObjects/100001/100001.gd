extends Sprite

onready var id = "100001"
onready var data = GameData.npcTable[self.id]
onready var sprite = preload("res://assets/npcSprites/100001/100001.png")
onready var spriteW = preload("res://assets/npcSprites/100001/100001w.png")
onready var avaliable_texture = preload("res://assets/npcSprites/npcBubbleSprites/QuestBubbleSprite.png")
onready var active_texture = preload("res://assets/npcSprites/npcBubbleSprites/ActiveQuestBubbleSprite.png")

onready var label = $Label
onready var anim = $AnimationPlayer
onready var dialog_index = 0
onready var dialog_bubble = $ChatBox
onready var dialog_timer = $DialogTimer
onready var quest_bubble = $QuestBubble

onready var dialog_box = preload("res://scenes/userInerface/Dialog.tscn")

#var clicked = false

func _ready() -> void:
	Signals.connect("update_quest_log", self, "update_bubble")
	label.text = data.name
	dialog_timer.start()
	update_bubble()
	
func _on_Area2D_input_event(viewport, event, shape_idx) -> void:
	#if can_interact:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("popup dialog for npc")
			Signals.emit_signal("toggle_dialog", self.id)
			

func move(location) -> void:
	if location.x < position.x:
		self.flip_h = true
		self.texture = spriteW
		self.set_position(location)
	elif location.x > position.x:
		self.flip_h = false
		self.texture = spriteW
		self.set_position(location)
	else:
		self.texture = sprite

# keeps bubble open
func _on_DialogTimer_timeout():
	dialog_bubble.display_text(data.bubbleDialog[dialog_index])
	if dialog_index + 1 == data.bubbleDialog.size():
		dialog_index = 0
	else:
		dialog_index += 1

func _on_Area2D_mouse_entered():
	print("dectect mouse")

func update_bubble():
	# 1 = avaliable 2 = active
	var bubble_status = 0
	
	# quest index tracker
	var quest_id = 0
	for quest in Global.quest_data:
		# if quest avaliable and npcstart == self and bubble_status is null and player level >= required level
		if quest[0] == -1 and str(GameData.questTable[str(quest_id)].npcStart) == self.id and not bubble_status and Global.player.stats.base.level >= GameData.questTable[str(quest_id)].levelReq:
			if GameData.questTable[str(quest_id)].preReq:
				if Global.quest_data[GameData.questTable[str(quest_id)].preReq][0] == 9:
					bubble_status = 1
			else:
				bubble_status = 1
		elif quest[0] == 0 and str(GameData.questTable[str(quest_id)].npcEnd) == self.id and quest[0] != 9:
			bubble_status = 2
			break
		quest_id += 1
		
	if bubble_status == 1:
		quest_bubble.texture = avaliable_texture
		if not quest_bubble.visible:
			quest_bubble.visible = true
	elif bubble_status == 2:
		quest_bubble.texture = active_texture
		if not quest_bubble.visible:
			quest_bubble.visible = true
	else:
		quest_bubble.visible = false
