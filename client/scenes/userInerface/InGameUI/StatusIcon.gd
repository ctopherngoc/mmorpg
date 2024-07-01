extends Sprite

onready var sprite_dict = {
	"heal": 0,
	"confuse": 1,
	"sleep": 2,
	"fast": 3,
	"frozen": 4,
	"bleed": 5,
	"poison": 6,
	"burn": 7,
	"seduce": 8,
	"protect": 9,
	"slow": 10,
	"shock": 11
}

func _ready():
	pass

func change_status_icon(status: String) -> void:
	self.frame = sprite_dict[status]
	
func remove_status_icon() -> void:
	self.queue_free()
