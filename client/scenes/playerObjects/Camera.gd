extends Camera2D

var target_position = Vector2.ZERO
export(Color, RGB) var background_color

func _ready():
	VisualServer.set_default_clear_color(background_color)

func _process(delta):
	acquire_target_position()
	global_position.x = lerp(target_position.x, global_position.x, pow(2, -25 * delta))
	global_position.y = target_position.y - 250
func acquire_target_position():
	var players = get_tree().get_nodes_in_group('player')
	if(players.size() > 0):
		var player = players[0]
		target_position = player.global_position
