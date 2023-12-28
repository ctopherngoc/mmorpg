extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_health", self, "update_health")
# warning-ignore:return_value_discarded
	Signals.connect("update_mana", self, "update_mana")
# warning-ignore:return_value_discarded
	Signals.connect("update_level", self, "update_level")
# warning-ignore:return_value_discardeds
# warning-ignore:return_value_discarded
	Signals.connect("update_exp", self, "update_exp")
# warning-ignore:return_value_discarded
	Signals.connect("update_displayname", self, "update_displayname")
	load_info()

#have to round to whole numbers
func update_health():
	$health/Label.text = str(Global.player.stats.base.health) + "/" + str(Global.player.stats.base.maxHealth)
	$health/TextureProgress.value = (float(Global.player.stats.base.health) / float(Global.player.stats.base.maxHealth))* 100
#have to round to whole numbers
func update_mana():
	$mana/Label.text = str(Global.player.stats.base.mana) + "/" + str(Global.player.stats.base.maxMana)
	$mana/TextureProgress.value = float((Global.player.stats.base.mana) / float(Global.player.stats.base.maxMana)) * 100

func update_level():
	$level/Label.text = str(Global.player.stats.base.level)
	#have to round to whole numbers
# for xp to show up as percentage, maximum xp for level must be stored and transferred
func update_exp():
	var exp_percent = (float(Global.player.stats.base.experience) / float(GameData.experience_table[str(Global.player.stats.base.level)])) * 100
	$exp/Label.text = str(Global.player.stats.base.experience) + "/" + str(GameData.experience_table[str(Global.player.stats.base.level)]) + ("%10.2f" % exp_percent) + "%"
	$exp/TextureProgress.value = exp_percent

func update_displayname():
	$displayname/Label.text = str(Global.player.displayname)
	
func update_job():
	$job/Label.text = str(GameData.job_dict[str(Global.player.stats.base.job)])
	
func load_info():
	update_displayname()
	update_health()
	update_mana()
	update_exp()
	update_level()
	update_job()
