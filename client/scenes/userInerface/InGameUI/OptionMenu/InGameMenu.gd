extends Control

onready var QuitConfirm = $QuitConfirm
onready var AnimPlayer = $AnimationPlayer
onready var OptionMenu = $Options
onready var MenuMenu = $menu
onready var ConfirmMenu = $QuitConfirm

onready var confirmButton
onready var cancelButton


func _ready():
	#confirmButton = ConfirmMenu.get_ok()
	#cancelButton = ConfirmMenu.get_cancel()
	ConfirmMenu.get_ok().connect("pressed", self, "button_click")
	ConfirmMenu.get_ok().connect("mouse_entered", self, "button_hover")
	ConfirmMenu.get_ok().focus_mode = Control.FOCUS_NONE
	ConfirmMenu.get_cancel().connect("pressed", self, "button_click")
	ConfirmMenu.get_cancel().connect("mouse_entered", self, "button_hover")
	ConfirmMenu.get_cancel().focus_mode = Control.FOCUS_NONE
# warning-ignore:return_value_discarded
	Signals.connect("toggle_options", self, "toggle_options")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if OptionMenu.visible:
			MenuMenu.set_visible(false)
			OptionMenu.set_visible(false)
		if !self.visible:
			MenuMenu.set_visible(true)
		else:
			#get_tree().set_pause(false)
			MenuMenu.set_visible(false)

func _on_Start_button_down():
	#SoundManager.PlayButtonPressUp()
	AnimPlayer.play("loading")

func _on_Options_button_down():
	play_button_pressed()
	MenuMenu.hide()
	OptionMenu.show()

func _on_End_button_down():
	play_button_pressed()
	#SoundManager.PlayFX(SoundManager.ErrorSound)

	QuitConfirm.popup_centered_ratio(.2)
# warning-ignore:unused_variable
	var OkayButton = QuitConfirm.get_ok()
	#OkayButton.grab_focus()
	
func _on_AcceptDialog_confirmed():
	QuitConfirm.hide()
	_on_resume_pressed()
	Server.logout()

func LoadNextScene():
	pass
	#SoundManager.TrackAnim.play("hide")
	#SceneManager.ChangeScene(NextScene)

func _on_back_pressed():
	MenuMenu.show()
	OptionMenu.hide()

func _on_resume_pressed():
	play_button_pressed()
	Signals.emit_signal("toggle_option_bool")
	self.hide()

func _on_Back_button_down():
	MenuMenu.show()

func _on_Button_mouse_entered():
	AudioControl.play_audio("menuHover")

func play_button_pressed():
	AudioControl.play_audio("menuHover")

func button_click() -> void:
	AudioControl.play_audio("menuClick")

func button_hover() -> void:
	AudioControl.play_audio("menuHover")

func toggle_options() -> void:
	self.visible = not self.visible
