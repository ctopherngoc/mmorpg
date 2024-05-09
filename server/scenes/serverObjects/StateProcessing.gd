extends Node

var sync_clock_counter = 0

var world_state = {}

func _physics_process(_delta):
	sync_clock_counter += 1
	if sync_clock_counter == 3:
		sync_clock_counter = 0
		#print(ServerData.monsters)
		if not ServerData.player_state_collection.empty():
			
			world_state["P"] = ServerData.player_state_collection.duplicate(true)
			#remove timestamp for each player, add timestamp to worldstate
			for player in world_state["P"].keys():
				world_state["P"][player].erase("T")
			world_state["T"] = OS.get_system_time_msecs()
			
			# transfers global dictionary of list of monsters in each map
			# dictionary keys are mapname
			
			world_state["E"] = ServerData.monsters.duplicate(true)
			world_state["I"] = ServerData.items.duplicate(true)
			
			#verification
			
			#anti-cheat
			
			#cuts (chunking / maps)
			
			# Physics checks
			
			#anything else
			#print(world_state)
			
			get_parent().send_world_state(world_state)
			
