extends HBoxContainer

onready var SoundSlider = $Sliders/SoundSlider
onready var EffectSlider = $Sliders/EffectsSlider
onready var MasterSlider = $Sliders/MasterSlider
onready var masterValue: float
onready var musicValue: float
onready var effectValue: float
#onready var menuStream = $menuStream
#Global.bgm.set_stream(GameData.bgm_dict["menu"])
#onready var menu_click = $audioStreams/click
#onready var menu_hover = $audioStreams/hover
onready var load_settings = false
func _ready() -> void:
	pass
	#SoundSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.BG_MUSIC_BUS)))
	#EffectSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.MENU_EFFECT_BUS)))
	#MasterSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.MASTER_BUS)))

# warning-ignore:unused_argument
func _on_SoundSlider_value_changed(value: float) -> void:
	if load_settings:
		AudioControl.play_audio("menuClick")
	var sfx_index= AudioServer.get_bus_index("Music")
	musicValue = value
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.BG_MUSIC_BUS, linear2db(value))

# warning-ignore:unused_argument
func _on_EffectsSlider_value_changed(value: float) -> void:
	if load_settings:
		AudioControl.play_audio("menuClick")
	var sfx_index= AudioServer.get_bus_index("Effects")
	effectValue = value
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.MENU_EFFECT_BUS, linear2db(value))

# warning-ignore:unused_argument
func _on_MasterSlider_value_changed(value: float) -> void:
	if load_settings:
		AudioControl.play_audio("menuClick")
	var sfx_index= AudioServer.get_bus_index("Master")
	masterValue = value
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.MASTER_BUS, linear2db(value))

func save_sound_values() -> void:
	effectValue = EffectSlider.value
	masterValue = MasterSlider.value
	musicValue = SoundSlider.value

func set_sound_values() -> void:
	var sfx_index= AudioServer.get_bus_index("Music")
	SoundSlider.value = musicValue
	AudioServer.set_bus_volume_db(sfx_index, linear2db(musicValue))
	sfx_index = AudioServer.get_bus_index("Master")
	MasterSlider.value = masterValue
	AudioServer.set_bus_volume_db(sfx_index, linear2db(masterValue))
	sfx_index = AudioServer.get_bus_index("Effects")
	EffectSlider.value = effectValue
	AudioServer.set_bus_volume_db(sfx_index, linear2db(effectValue))
	load_settings = true
