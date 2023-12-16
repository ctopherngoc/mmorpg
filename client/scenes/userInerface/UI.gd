extends CanvasLayer

onready var QuitConfirm = $InGameMenu/QuitConfirm
onready var AnimPlayer = $InGameMenu/AnimationPlayer
onready var OptionMenu = $InGameMenu/Options
onready var MenuMenu = $InGameMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.ui = $PlayerHUD

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if !MenuMenu.visible:
			#get_tree().set_pause(true)
			MenuMenu.set_visible(true)
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			#get_tree().set_pause(false)
			MenuMenu.set_visible(false)
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	
func focus_entered():
	pass
	#SoundManager.PlayMouseEffect()
	
func _on_Start_button_down():
	#SoundManager.PlayButtonPressUp()
	AnimPlayer.play("loading")

func _on_Options_button_down():
	#SoundManager.PlayButtonPressUp()
	MenuMenu.hide()
	OptionMenu.show()

func _on_End_button_down():
	#SoundManager.PlayFX(SoundManager.ErrorSound)

	QuitConfirm.popup_centered_ratio(.2)
	var OkayButton = QuitConfirm.get_ok()
	OkayButton.grab_focus()
	
func _on_AcceptDialog_confirmed():
	QuitConfirm.hide()
	_on_resume_pressed()
	#SceneManager.ChangeScene("res://Menu/MainMenu/MainMenu2.tscn")

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
	MenuMenu.hide()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_tree().set_pause(false)

func _on_Back_button_down():
	#SoundManager.PlayButtonPressDown()
	MenuMenu.show()
