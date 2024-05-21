extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("update_health", self, "update_health")
# warning-ignore:return_value_discarded
	Signals.connect("update_mana", self, "update_mana")
# warning-ignore:return_value_discarded
	Signals.connect("update_level", self, "update_level")
# warning-ignore:return_value_discarded
	Signals.connect("update_exp", self, "update_exp")
# warning-ignore:return_value_discarded
	Signals.connect("update_displayname", self, "update_displayname")
	load_info()

#have to round to whole numbers
func update_health() -> void:
	$Control/HBoxContainer/fillBars/hpmpBar/HealthVBar/Control/Number.text = str(Global.player.stats.base.health) + "/" + str(Global.player.stats.base.maxHealth)
	$Control/HBoxContainer/fillBars/hpmpBar/HealthVBar/Control/TextureProgress.value = (float(Global.player.stats.base.health) / float(Global.player.stats.base.maxHealth))* 100
#have to round to whole numbers
func update_mana() -> void:
	$Control/HBoxContainer/fillBars/hpmpBar/MPVBar/Control/Number.text = str(Global.player.stats.base.mana) + "/" + str(Global.player.stats.base.maxMana)
	$Control/HBoxContainer/fillBars/hpmpBar/MPVBar/Control/TextureProgress.value = float((Global.player.stats.base.mana) / float(Global.player.stats.base.maxMana)) * 100

func update_level() -> void:
	$Control/HBoxContainer/characterInfo/LVLHBox/Number.text = str(Global.player.stats.base.level)
	#have to round to whole numbers
# for xp to show up as percentage, maximum xp for level must be stored and transferred
func update_exp() -> void:
	var exp_percent = (float(Global.player.stats.base.experience) / float(GameData.experience_table[str(Global.player.stats.base.level)])) * 100
	$Control/HBoxContainer/fillBars/EXPVBar/Control/Number.text = str(Global.player.stats.base.experience) + "/" + str(GameData.experience_table[str(Global.player.stats.base.level)]) + ("%10.2f" % exp_percent) + "%"
	$Control/HBoxContainer/fillBars/EXPVBar/Control/TextureProgress.value = exp_percent

func update_displayname() -> void:
	$Control/HBoxContainer/characterInfo/username.text = str(Global.player.displayname)
	
func update_job() -> void:
	$Control/HBoxContainer/characterInfo/job.text = str(GameData.job_dict[str(Global.player.stats.base.job)])
	
func load_info() -> void:
	update_displayname()
	update_health()
	update_mana()
	update_exp()
	update_level()
	update_job()
