extends Node2D
var map_node: Node2D
var player: KinematicBody2D
var ui: CanvasLayer
var map: Node2D

func _ready() -> void:
	map_node = $MapNode
	#player = $Player
	ui = $UI
	var new_map = load(GameData.map_dict[Global.current_map].path).instance()
	#new_map.name = "Map"
	map_node.add_child(new_map)
	#map_node.get_children()[0].name = "Map"
	map = map_node.get_children()[0]
	
func load_map(map_path: String) -> void:
	#instance next map
	var next_map = load(map_path).instance()
	#next_map.name = "Map"
	
	# if changing maps
	# after chosing character no prev map -> sk[
	#if world_node.get_child_count() > 0:
	map.queue_free()
	map_node.add_child(next_map)
	#map_node.get_children()[0].name = "Map"
	map = map_node.get_children()[1]
