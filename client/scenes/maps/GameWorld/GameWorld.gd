extends Node2D
var map_node: Node2D
var player: KinematicBody2D
var ui: CanvasLayer
var map: Node2D

func _ready() -> void:
	map_node = $MapNode
	ui = $UI

	var new_map = load(GameData.map_dict[Global.current_map].path).instance()
	map_node.add_child(new_map)
	map = map_node.get_children()[0]
	
func load_map(map_path: String):
	#instance next map
	var next_map = load(map_path).instance()
	
	map.queue_free()
	map_node.add_child(next_map)
	map = map_node.get_children()[1]
