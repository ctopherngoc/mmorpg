extends Control


onready var QuitConfirm = $QuitConfirm
onready var AnimPlayer = $AnimationPlayer
onready var OptionMenu = $Options
onready var MenuMenu = $menu

export(String, FILE, "*.tscn") var NextScene
var Paused

func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if OptionMenu.visible:
			MenuMenu.set_visible(false)
			OptionMenu.set_visible(false)
		if !self.visible:
			#get_tree().set_pause(true)
			MenuMenu.set_visible(true)
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			#get_tree().set_pause(false)
			MenuMenu.set_visible(false)
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Start_button_down():
	#SoundManager.PlayButtonPressUp()
	AnimPlayer.play("loading")

func _on_Options_button_down():
	#SoundManager.PlayButtonPressUp()
	MenuMenu.hide()
	OptionMenu.show()

func _on_End_button_down():
	pass
	#SoundManager.PlayFX(SoundManager.ErrorSound)

	QuitConfirm.popup_centered_ratio(.2)
	var OkayButton = QuitConfirm.get_ok()
	#OkayButton.grab_focus()
	
func _on_AcceptDialog_confirmed():
	QuitConfirm.hide()
	_on_resume_pressed()
	#SceneManager.ChangeScene("res://Menu/MainMenu/MainMenu2.tscn")
	Global.logging_out = true
	Global.world_state_buffer.clear()
	Server.logout()
	#SceneHandler.change_scene("login")

func LoadNextScene():
	pass
	#SoundManager.TrackAnim.play("hide")
	#SceneManager.ChangeScene(NextScene)

func _on_back_pressed():
	#SoundManager.PlayButtonPressDown()
	MenuMenu.show()
	OptionMenu.hide()

func _on_resume_pressed():
	#SoundManager.TrackAnim.play("hide")
	self.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_tree().set_pause(false)

func _on_Back_button_down():
	#SoundManager.PlayButtonPressDown()
	MenuMenu.show()
