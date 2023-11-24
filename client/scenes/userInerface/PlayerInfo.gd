extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_health", Callable(self, "update_health"))
# warning-ignore:return_value_discarded
	Signals.connect("update_mana", Callable(self, "update_mana"))
# warning-ignore:return_value_discarded
	Signals.connect("update_level", Callable(self, "update_level"))
# warning-ignore:return_value_discarded
	Signals.connect("update_exp", Callable(self, "update_exp"))
# warning-ignore:return_value_discarded
	Signals.connect("update_displayname", Callable(self, "update_displayname"))
	load_info()

func update_health():
	$health/Label.text = str(Global.player["stats"]["health"])

func update_mana():
	$mana/Label.text = str(Global.player["stats"]["mana"])
	
func update_level():
	$level/Label.text = str(Global.player["stats"]["level"])
	
# for xp to show up as percentage, maximum xp for level must be stored and transferred
func update_exp():
	var exp_percent = (Global.player["stats"]["experience"] / GameData.experience_table[str(Global.player["stats"]["level"])]) * 100
	$exp/Label.text = "%10.2f" % exp_percent

func update_displayname():
	$displayname/Label.text = str(Global.player["displayname"])
	
func update_job():
	$job/Label.text = str(GameData.job_dict[str(Global.player["stats"]["job"])])
	
func load_info():
	update_displayname()
	update_health()
	update_mana()
	update_exp()
	update_level()
	update_job()
