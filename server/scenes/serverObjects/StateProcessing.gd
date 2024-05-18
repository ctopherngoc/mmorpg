extends Node

var sync_clock_counter = 0

#var world_state = {}

func _physics_process(_delta: float) -> void:
	sync_clock_counter += 1
	if sync_clock_counter == 3:
		sync_clock_counter = 0
		#print(ServerData.monsters)
			
		if not ServerData.player_state_collection.empty():
			var map_list = Global.maps.get_children()
			
			"""
			for map in map list
				fill dictionary with P E I 
			add T
			call server.send_world_state(list of players in current map, poolbytearray of map_world state)
			"""
			for map_node in map_list:
				var map_state = {}
				map_state["E"] = ServerData.monsters[map_node.name].duplicate(true)
				map_state["I"] = ServerData.items[map_node.name].duplicate(true)
				map_state["P"] = {}
				for player_node in map_node.players:
					"""
					####this is important
					player container gets added to map after character select
					gets added into map.players[] but player state is not process
					so player state not in serverdata.player_state_collection
					
					going to search for state in collection and crash
					
					skips one tick of player state so collection can be updated with real info
					"""
					if int(player_node.name) in ServerData.player_state_collection.keys():
						map_state["P"][int(player_node.name)] = ServerData.player_state_collection[int(player_node.name)].duplicate(true)
						map_state["P"][int(player_node.name)].erase("T")
				var player_list = map_state["P"].keys()
				map_state["T"] = OS.get_system_time_msecs()
				get_parent().send_world_state(player_list, var2bytes(map_state))
#
#			#verification
#
#			#anti-cheat
#
#			#cuts (chunking / maps)
#
#			# Physics checks
#
