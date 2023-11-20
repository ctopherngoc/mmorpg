extends ColorRect

"""
var health = Global.player["stats"]["health"] 
var mana = Global.player["stats"]["mana"] 
var level = Global.player["stats"]["level"] 
var experience = Global.player["stats"]["experience"]
"""
# Called when the node enters the scene tree for the first time.
func _ready():
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

func update_health():
	$health/Label.text = str(Global.player["stats"]["health"])

func update_mana():
	$mana/Label.text = str(Global.player["stats"]["mana"])
	
func update_level():
	$level/Label.text = str(Global.player["stats"]["level"])
	
# for xp to show up as percentage, maximum xp for level must be stored and transferred
func update_exp():
	$exp/Label.text = str(Global.player["stats"]["experience"])

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
