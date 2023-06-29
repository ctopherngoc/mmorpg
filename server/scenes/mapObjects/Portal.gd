extends Area2D

#export(String, FILE, "*.tscn, *.scn") var target_scene
func _read():
	pass

func over_lapping_bodies(player_id):
	if get_overlapping_bodies().size() > 0:
		print(get_overlapping_bodies())
		for player_container in get_overlapping_bodies():
			if player_container.name == str(player_id):
				print("%s: confirm" % self.name + " %s on portal" % player_id)
	else:
		print("no overlapping bodies")
