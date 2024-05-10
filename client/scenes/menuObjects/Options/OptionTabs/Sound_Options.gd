extends HBoxContainer

onready var SoundSlider = $Sliders/SoundSlider
onready var EffectSlider = $Sliders/EffectsSlider
onready var MasterSlider = $Sliders/MasterSlider

func _ready():
	pass
	#SoundSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.BG_MUSIC_BUS)))
	#EffectSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.MENU_EFFECT_BUS)))
	#MasterSlider.set_value(db2linear(SoundManager.GetBusVolume(SoundManager.MASTER_BUS)))

# warning-ignore:unused_argument
func _on_SoundSlider_value_changed(value):
	var sfx_index= AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.BG_MUSIC_BUS, linear2db(value))

# warning-ignore:unused_argument
func _on_EffectsSlider_value_changed(value):
	var sfx_index= AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.MENU_EFFECT_BUS, linear2db(value))

# warning-ignore:unused_argument
func _on_MasterSlider_value_changed(value):
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, linear2db(value))
	#SoundManager.ChangeVolume(SoundManager.MASTER_BUS, linear2db(value))

