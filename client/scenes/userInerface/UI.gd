extends CanvasLayer

onready var QuitConfirm = $Control/InGameMenu/QuitConfirm
onready var AnimPlayer = $Control/InGameMenu/AnimationPlayer
onready var OptionMenu = $Control/InGameMenu/Options
onready var MenuMenu = $Control/InGameMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func focus_entered() -> void:
	pass
	
func _on_Start_button_down() -> void:
	AnimPlayer.play("loading")

func _on_Options_button_down() -> void:
	MenuMenu.hide()
	OptionMenu.show()

func _on_End_button_down() -> void:
	#SoundManager.PlayFX(SoundManager.ErrorSound)

	QuitConfirm.popup_centered_ratio(.2)
	var OkayButton = QuitConfirm.get_ok()
	OkayButton.grab_focus()
	
func _on_AcceptDialog_confirmed():
	QuitConfirm.hide()
	_on_resume_pressed()

func LoadNextScene() -> void:
	pass

func _on_resume_pressed() -> void:
	AudioControl.play_audio("menuClick")
	MenuMenu.hide()

func toggle_ui() -> void:
	self.visible = !self.visible
