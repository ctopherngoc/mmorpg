extends Control


onready var QuitConfirm = $QuitConfirm
onready var AnimPlayer = $AnimationPlayer
onready var OptionMenu = $Options
onready var MenuMenu = $menu

onready var HowToPlay = $HowToPlay

export(String, FILE, "*.tscn") var NextScene
var Paused

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if !get_tree().is_paused():
			get_tree().set_pause(true)
			set_visible(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().set_pause(false)
			set_visible(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
func focus_entered():
	SoundManager.PlayMouseEffect()
	
func _on_Start_button_down():
	SoundManager.PlayButtonPressUp()
	AnimPlayer.play("loading")

func _on_Options_button_down():
	SoundManager.PlayButtonPressUp()
	MenuMenu.hide()
	OptionMenu.show()

func _on_End_button_down():
	SoundManager.PlayFX(SoundManager.ErrorSound)

	QuitConfirm.popup_centered_ratio(.2)
	var OkayButton = QuitConfirm.get_ok()
	OkayButton.grab_focus()
	
func _on_AcceptDialog_confirmed():
	QuitConfirm.hide()
	_on_resume_pressed()
	SceneManager.ChangeScene("res://Menu/MainMenu/MainMenu2.tscn")

func LoadNextScene():
	SoundManager.TrackAnim.play("hide")
	SceneManager.ChangeScene(NextScene)

func _on_back_pressed():
	SoundManager.PlayButtonPressDown()
	MenuMenu.show()
	OptionMenu.hide()

func _on_resume_pressed():
	SoundManager.TrackAnim.play("hide")
	self.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().set_pause(false)

func _on_Back_button_down():
	SoundManager.PlayButtonPressDown()
	MenuMenu.show()
	HowToPlay.hide()
