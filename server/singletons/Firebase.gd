extends Node
onready var PROJECT_ID
onready var DATABASE_URL: String
onready var LOGIN_URL: String
onready var FB_USERNAME: String
onready var FB_PASSWORD: String
var user_info := {}
var server_token = ""

func _ready():
	var data_file = File.new()
	data_file.open("res://data/server.json", File.READ)
	var server_json = JSON.parse(data_file.get_as_text())
	PROJECT_ID = server_json.result["PROJECT_ID"]
	DATABASE_URL = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % server_json.result["PROJECT_ID"]
	LOGIN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % server_json.result["API_KEY"]
	FB_USERNAME = server_json.result["USERNAME"]
	FB_PASSWORD = server_json.result["PASSWORD"]
	data_file.close()

func _get_request_headers(token_id: String) -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % token_id
	])

# only when creating an account
# create baseline in /users and chreating new character in /characters
func save_document(path: String, fields: Dictionary, token: String)-> void:
	var document := {"fields": fields}
	var body := to_json(document)
	var url := DATABASE_URL + path
	var temp_HTTP = HTTPRequest.new()
	self.add_child(temp_HTTP)
# warning-ignore:return_value_discarded
	if "users/" in path:
		temp_HTTP.request(url, _get_request_headers(token),false, HTTPClient.METHOD_POST, body)
		yield(temp_HTTP, "request_completed")
	else:
# warning-ignore:return_value_discarded
		temp_HTTP.request(url, _get_request_headers(token),false, HTTPClient.METHOD_POST, body)
		yield(temp_HTTP, "request_completed")
	temp_HTTP.queue_free()
	
# saving characters/updating information
# creating new characters in /users
func update_document(path: String, token: String, data) -> void:
	var temp_HTTP = HTTPRequest.new()
	self.add_child(temp_HTTP)
	if 'users/' in path:
		# convert
		var character_array = []
		for character in data.characters:
			character_array.append({'stringValue':str(character)})
		var temp_dict = {'characters':{'arrayValue':{'values': character_array}}}
		var document := {"fields": temp_dict}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		temp_HTTP.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(temp_HTTP, "request_completed")
		
	elif 'items/' in path:
		var fb_data = ServerData.static_data.fb_equipment_template.duplicate(true)
# warning-ignore:return_value_discarded
		item_data_converter(data, fb_data)
		var document := {"fields": fb_data}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		temp_HTTP.request(url, _get_request_headers(server_token), false, HTTPClient.METHOD_PATCH, body)
		yield(temp_HTTP, "request_completed")
		
	elif 'characters/' in path:
		# update /character
		var fb_data = ServerData.static_data.player_info.duplicate(true)
		server_dictionary_converter(data, fb_data)
		var document := {"fields": fb_data}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		temp_HTTP.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(temp_HTTP, "request_completed")
	
	temp_HTTP.queue_free()

func delete_document(path: String, token: String) -> void:
	
	var temp_HTTP = HTTPRequest.new()
	self.add_child(temp_HTTP)
	var url := DATABASE_URL + path
	temp_HTTP.request(url, _get_request_headers(token), false, HTTPClient.METHOD_DELETE)
	yield(temp_HTTP, "request_completed")
	temp_HTTP.queue_free()
	
func firebase_dictionary_converter(database_data: Dictionary, client_data: Array) -> void:
	"""
	takes firebase json dictionary converts to normal dictionary and appends to an array
	"""
	var temp_dict = {}

	# displayname and position
	temp_dict['displayname'] = database_data["displayname"]['stringValue']
	temp_dict['map'] = database_data["map"]['integerValue']

	# stats
	var shortcut = database_data["stats"]["mapValue"]["fields"]
	temp_dict['stats'] = {
		"base": {}, 
		"equipment": {}
		}
	for key in shortcut.keys():
		var shortcut2 = shortcut[key]["mapValue"]["fields"]
		var keys2 = shortcut2.keys()
		for key2 in keys2:
			# added situation if value saved as integervalue
			temp_dict['stats'][key][key2] = int(shortcut2[key2]['integerValue'])
	# avatar
	shortcut = database_data["avatar"]["mapValue"]["fields"]
	temp_dict['avatar'] = {}
	for key in shortcut.keys():
		# added situation if value saved as integervalue
		temp_dict['avatar'][key] = shortcut[key]['stringValue']

	# equipment
	shortcut = database_data["equipment"]["mapValue"]["fields"] 
	temp_dict['equipment'] = {}
	"""
	currently player equips are set to either = -1, item_id and rweapon = dictionary
	"""
	for equipment in shortcut.keys():
		# for item_id
		# need to update to dictionary
		if 'integerValue' in shortcut[equipment].keys():
			temp_dict['equipment'][equipment] = shortcut[equipment]['integerValue']
		# equipment with full dictionary
		else:
			temp_dict['equipment'][equipment] = {}
			var shortcut2 = shortcut[equipment]["mapValue"]["fields"]
			for stat in shortcut2.keys():
				if 'integerValue' in shortcut2[stat]:
					temp_dict['equipment'][equipment][stat] = shortcut2[stat]['integerValue']
				else:
					temp_dict['equipment'][equipment][stat] = shortcut2[stat]['stringValue']
	#inventory
	shortcut = database_data["inventory"]["mapValue"]["fields"]
	temp_dict['inventory'] = {}
	# for tab in inventory
	for item in shortcut.keys():
			# if gold
			if item == "100000":
				temp_dict['inventory'][item] = int(shortcut[item]['integerValue'])
			# tab keys [equips, use, etc]
			else:
				temp_dict['inventory'][item] = []
				var inventory_shortcut = shortcut[item]['arrayValue']['values'] # [item_dict, item_dict2, item_dict3]
				# in equips
				# inv['equipment'] = [equip_dict1, equip_dict2...]
				if item == "equipment":
					#currently have [equip_dict1, equip_dict2...]
					var count = 0
					for equip_dict in inventory_shortcut:
						#for each equip dict if null
						if 'nullValue' in equip_dict:
							temp_dict['inventory'][item].append(null)
						# equip_dict not null
						else:
							# now in equip{}
							var equip_shortcut = equip_dict["mapValue"]["fields"]
							for equip_key in equip_shortcut.keys():
								temp_dict['inventory'][item][count] = {}
								var shortcut2 = equip_shortcut[equip_key]["mapValue"]["fields"]
								for stat in shortcut2.keys():
									if 'integerValue' in shortcut2[stat]:
										temp_dict['inventory'][item][count][stat] = shortcut2[stat]['integerValue']
									else:
										temp_dict['inventory'][item][count][stat] = shortcut2[stat]['stringValue']
							count += 1
				# for use, etc tab
				else:
					for item_dict in inventory_shortcut:
						if 'nullValue' in item_dict:
							temp_dict['inventory'][item].append(null)
						else:
							var item_slot = item_dict['mapValue']['fields']
							var item_slot_keys = item_slot.keys()
							var temp_item_dict = {}
							
							for data in item_slot_keys:
								if 'integerValue' in item_slot[data]:
									temp_item_dict[data] = int(item_slot[data]['integerValue'])
								elif 'nullValue' in item_slot[data]:
									temp_item_dict[data] = null;
								else:
									temp_item_dict[data] = str(item_slot[data]['stringValue'])
							temp_dict['inventory'][item].append(temp_item_dict)
	
	#keybinds
	if "keybind" in database_data.keys():
		shortcut = database_data["keybind"]["mapValue"]["fields"]
		var keys = shortcut.keys()
		temp_dict['keybind'] = {}
		for key in keys:
			if 'nullValue' in shortcut[key].keys():
				temp_dict['keybind'][key] = null
			else:
				temp_dict['keybind'][key] = str(shortcut[key]['stringValue'])
	else:
		temp_dict['keybind'] = ServerData.static_data.default_keybind.duplicate(true)
	client_data.append(temp_dict)

# used only by server (server user)
###############################################################################
###############################################################################
###############################################################################
func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return {
		"token" : result_body.idToken,
		"id" : result_body.localId,
		"timestamp" : OS.get_unix_time(),
	}

func login(email: String, password: String, results: Array) -> void:
	var temp_HTTP = HTTPRequest.new()
	self.add_child(temp_HTTP)
	var body := {
		'email': email,
		'password': password,
		'returnSecureToken': true
	}
	# warning-ignore:return_value_discarded
	temp_HTTP.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(temp_HTTP, "request_completed") as Array

	if result[1] == 200:
		"""
		return something here for AuthenticatePlayer to confirm 
		response code 200 = successful
		results = [_get_user_info(result), response code ]
		"""
		results.append(result[1])
		results.append(_get_user_info(result))
	
	else:
		results.append(result[1])
	temp_HTTP.queue_free()

func get_data(username: String, password: String):
	print("starting to get data")
	var results = []
	var firebaseStatus = login(username, password, results)
	yield(firebaseStatus, "completed")
	if results[0] != 200:
		print("Server Signin Unsuccessful")
		return get_data(username, password)
	else:
		print("Server Signin Successful")
		server_token = results[1]['token']
		var accounts_call = _server_get_document("users/")
		yield(accounts_call, 'completed')
		var characters_call = _server_get_document("characters/")
		yield(characters_call, 'completed')
		var items_call = _server_get_document("items/")
		yield(items_call, 'completed')
		print("data loaded")
		Global.server.start_server()
		HubConnection.connect_to_server()
		
func _server_get_document(path: String) -> void:
	var temp_HTTP = HTTPRequest.new()
	self.add_child(temp_HTTP)
	var url := DATABASE_URL + path
	# warning-ignore:return_value_discarded
	temp_HTTP.request(url, _get_request_headers(server_token), false, HTTPClient.METHOD_GET)
	var result := yield(temp_HTTP, "request_completed") as Array
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary

	if "users" in path:
		if "documents" in result_body.keys():
			var document_list = result_body["documents"]
			for document in document_list:
				var doc_id = document["name"].replace("projects/%s/databases/(default)/documents/users/" % PROJECT_ID, "")
				var character_list = []
				if document["fields"]['characters']['arrayValue'].size() > 0:
					for character in document["fields"]['characters']['arrayValue']['values']:
						character_list.append(character["stringValue"])
					ServerData.user_characters[doc_id] = character_list
				else:
					ServerData.user_characters[doc_id] = []

	# currently specific character
	elif "characters" in path:
		if "documents" in result_body.keys():
			var document_list = result_body["documents"]
			for document in document_list:
				var character = document["name"].replace("projects/%s/databases/(default)/documents/characters/" % PROJECT_ID, "")
				ServerData.characters_data[character] = server_firebase_dictionary_converter(document["fields"])

	elif "items" in path:
		if "documents" in result_body.keys():
			var document_list = result_body["documents"]
			for document in document_list:
				var item = document["name"].replace("projects/%s/databases/(default)/documents/items/" % PROJECT_ID, "")
				ServerData.equipment_data.append(str(item))
	
	temp_HTTP.queue_free()
	return 0
	
func server_firebase_dictionary_converter(database_data: Dictionary) -> Dictionary:
	"""
	takes firebase json dictionary converts to normal dictionary and appends to an array
	"""
	var temp_dict = {}

	# displayname and position
	temp_dict['displayname'] = database_data["displayname"]['stringValue']
	temp_dict['map'] = database_data["map"]['integerValue']

	# stats
	var shortcut = database_data["stats"]["mapValue"]["fields"]
	var keys = shortcut.keys()
	temp_dict['stats'] = {
		"base": {},
		"equipment" : {}
		}
	for key in keys:
		var shortcut2 = shortcut[key]["mapValue"]["fields"]
		var keys2 = shortcut2.keys()
		for key2 in keys2:
			# added situation if value saved as integervalue
			if key2 == "ap":
				var ap_array = []
				for ap in shortcut2[key2]["arrayValue"]["values"]:
					ap_array.append(int(ap['integerValue']))
				temp_dict['stats'][key][key2] = ap_array
				
			else:
				temp_dict['stats'][key][key2] = int(shortcut2[key2]['integerValue'])

	# avatar
	shortcut = database_data["avatar"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['avatar'] = {}
	for key in keys:
		# added situation if value saved as integervalue
		temp_dict['avatar'][key] = str(shortcut[key]['stringValue'])
	
	# skills
	if database_data.has("skills"):
		shortcut = database_data["skills"]["mapValue"]["fields"]
		keys = shortcut.keys()
		temp_dict['skills'] = {}
		var job_skills = {}
		for jobs in keys:
			var skill_shortcut = shortcut[jobs]["mapValue"]["fields"]
			job_skills[jobs] = {}
			for skill in skill_shortcut.keys():
				# added situation if value saved as integervalue
				job_skills[jobs][skill] = int(skill_shortcut[skill]['integerValue'])
		temp_dict['skills'] = job_skills.duplicate(true)

	# equipment
	shortcut = database_data["equipment"]["mapValue"]["fields"] 
	keys = shortcut.keys()
	temp_dict['equipment'] = {}
	#for equip in equip key list
	for key in keys:
		if 'integerValue' in shortcut[key].keys():
			var equipment_id = int(shortcut[key]['integerValue'])
			var item_dict = ServerData.equipmentTable[str(equipment_id)]
			var temp_item_keys = item_dict.keys()
			for temp_key in temp_item_keys:
				if item_dict[temp_key] == null:
					item_dict[temp_key] = 0
			item_dict["id"] = str(equipment_id)
			item_dict["uniqueID"] = str(Global.generate_unique_id(equipment_id))
			temp_dict['equipment'][key] = item_dict.duplicate(true)
			
		elif 'nullValue' in shortcut[key].keys():
			temp_dict['equipment'][key] = null
		else:
			temp_dict['equipment'][key] = {}
			var shortcut2 = shortcut[key]["mapValue"]["fields"]
			var keys2 = shortcut2.keys()
			for key2 in keys2:
				if 'integerValue' in shortcut2[key2]:
					temp_dict['equipment'][key][key2] = int(shortcut2[key2]['integerValue'])
				elif 'stringValue' in shortcut2[key2]:
					temp_dict['equipment'][key][key2] = str(shortcut2[key2]['stringValue'])
				elif 'nullValue' in shortcut2[key2]:
					temp_dict['equipment'][key][key2] = null
	#################################################################
	# remove this after finishing equipment update
	for equip in ["ring1", "ring2", "ring3"]:
		if not temp_dict['equipment'].has(equip):
			temp_dict['equipment'][equip] = null
	####################################################################
	
	#inventory
	shortcut = database_data["inventory"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['inventory'] = {}
	# for tab in inventory
	for key in keys:
			# if gold
			if key == "100000":
				temp_dict['inventory'][key] = int(shortcut[key]['integerValue'])
			# tab keys [equips, use, etc]
			else:
				temp_dict['inventory'][key] = []
				var inventory_shortcut = shortcut[key]['arrayValue']['values']
				# in equips
				if key == "equipment":
					#currently have [equip_dict1, equip_dict2...]
					var count = 0
					for equip_dict in inventory_shortcut:
						#for each equip dict if null
						if 'nullValue' in equip_dict.keys():
							temp_dict['inventory'][key].append(null)
						# equip_dict not null
						else:
							# now in equip{}
							var equip_shortcut = equip_dict["mapValue"]["fields"]
							var inv_equip_keys = equip_shortcut.keys()
							temp_dict['inventory'][key].append({})
							for equip_key in inv_equip_keys:
								# append inventory equipment
								var keys2 = equip_shortcut.keys()
								for key2 in keys2:
									if 'integerValue' in equip_shortcut[key2]:
										temp_dict['inventory'][key][count][key2] = int(equip_shortcut[key2]['integerValue'])
									else:
										temp_dict['inventory'][key][count][key2] = str(equip_shortcut[key2]['stringValue'])
						count += 1
				# for use, etc tab
				else:
					for item_dict in inventory_shortcut:
						if 'nullValue' in item_dict:
							temp_dict['inventory'][key].append(null)
						else:
							var item_slot = item_dict['mapValue']['fields']
							var item_slot_keys = item_slot.keys()
							var temp_item_dict = {}
							
							for data in item_slot_keys:
								if 'integerValue' in item_slot[data]:
									temp_item_dict[data] = int(item_slot[data]['integerValue'])
								elif 'nullValue' in item_slot[data]:
									temp_item_dict[data] = null;
								else:
									temp_item_dict[data] = str(item_slot[data]['stringValue'])
							temp_dict['inventory'][key].append(temp_item_dict)
	
	#keybinds
	if "keybind" in database_data.keys():
		shortcut = database_data["keybind"]["mapValue"]["fields"]
		keys = shortcut.keys()
		temp_dict['keybind'] = {}
		for key in keys:
			if 'nullValue' in shortcut[key].keys():
				temp_dict['keybind'][key] = null
			else:
				temp_dict['keybind'][key] = str(shortcut[key]['stringValue'])
	else:
		temp_dict['keybind'] = ServerData.static_data.default_keybind.duplicate(true)
	
	temp_dict.stats["buff"] = ServerData.buff_stats.duplicate(true)
	return temp_dict

func server_dictionary_converter(server_data: Dictionary, firebase_data: Dictionary) -> void:
	"""
	in: server dictionary
	out: firebase dictionary
	"""
	# displayname and position
	firebase_data['displayname']['stringValue'] = str(server_data["displayname"])
	firebase_data['map']['integerValue'] = int(server_data["map"])

	# stats
	var shortcut = server_data["stats"]
	var fb_shortcut = firebase_data['stats']['mapValue']['fields']
	# base, equipment, buffs
	for key in shortcut.keys():
		var shortcut_keys2 = shortcut[key].keys()
		if not key == "buff":
			# stats
			for key2 in shortcut_keys2:
				if key2 == "ap":
					var ap = []
					for job_ap in shortcut[key]["ap"]:
						ap.append({"integerValue": job_ap})
					fb_shortcut[key]['mapValue']['fields']["ap"]["arrayValue"]["values"] = ap
					########################################
				else:
					fb_shortcut[key]['mapValue']['fields'][key2]['integerValue'] = int(shortcut[key][key2])

	# avatar
	shortcut = server_data["avatar"]
	fb_shortcut = firebase_data['avatar']['mapValue']['fields']
	for key in shortcut.keys():
		fb_shortcut[key]['stringValue'] = str(shortcut[key])
	
	# skills
	shortcut = server_data["skills"]
	fb_shortcut = firebase_data['skills']['mapValue']['fields']

	# skills dictionary
	var fb_skill_dict = {}
	# list if job skills dicts
	for job in shortcut.keys():
		var skill_dict = {}
		# for each skill in job skills dict
		for skill in shortcut[job].keys():
			skill_dict[skill] = {}
			skill_dict[skill]['integerValue'] = shortcut[job][skill]
		fb_skill_dict[job] = {"mapValue": {'fields': {}}}
		fb_skill_dict[job]["mapValue"]["fields"] = skill_dict.duplicate(true)
	firebase_data['skills']['mapValue']['fields'] = fb_skill_dict.duplicate(true)
	#################################################################################################
	
	# equipment
	shortcut = server_data["equipment"]
	fb_shortcut = firebase_data['equipment']['mapValue']['fields']
	for key in shortcut.keys():
		# non implement gear are integers
		if typeof(shortcut[key]) == TYPE_INT:
			fb_shortcut[key]['integerValue'] = int(shortcut[key])
		# currently rweapon
		elif typeof(shortcut[key]) == TYPE_DICTIONARY:
			# weapon dict
			var temp_dict = ServerData.static_data.fb_equipment_template.duplicate(true)
			# [equipment][rweapon]
			var shortcut2 = shortcut[key]
			var keys2 = shortcut2.keys()
			# rweapon dict
			for key2 in keys2:
				if typeof(shortcut2[key2]) == TYPE_STRING:
					temp_dict[key2] = {'stringValue' : shortcut2[key2]}
				elif typeof(shortcut2[key2]) == TYPE_INT:
					temp_dict[key2] = {'integerValue': shortcut2[key2]}
				elif typeof(shortcut2[key2]) == TYPE_NIL:
					temp_dict[key2] = {'nullValue': null}
			fb_shortcut[key] = {'mapValue':{'fields': temp_dict}}
		elif typeof(shortcut[key]) == TYPE_NIL:
			fb_shortcut[key]['nullValue'] = null
#####################################################################################################

	#inventory
	shortcut = server_data["inventory"]
	fb_shortcut = firebase_data['inventory']['mapValue']['fields']
	for key in shortcut.keys():
		# inventory gold
		if key == "100000":
			fb_shortcut[key] = {'integerValue': int(shortcut[key])}
		else:
			# inventory equipment
			if key == "equipment":
				var fb_equip_shortcut = fb_shortcut[key]["arrayValue"]["values"]
				# for dict in dict_array
				var count = 0
				for equip in shortcut["equipment"]:
					if equip != null:
						var temp_dict = ServerData.static_data.equipment_data_template.duplicate(true)
						# equip dict
						for stat in equip.keys():
							if stat in ['id', 'uniqueID', 'type', 'name', 'owner']:
								temp_dict[stat] = {'stringValue' : str(equip[stat])}
							else:
								temp_dict[stat] = {'integerValue': int(equip[stat])}
						fb_equip_shortcut[count] = {'mapValue':{'fields': temp_dict}}
					count += 1
			# etc, use
			else:
				var item_shortcut = fb_shortcut[key]['arrayValue']['values']
				var count = 0
				for item in shortcut[key]:
					if item != null:
						# temp item dictionary
						var item_dict = {}
						# for item keys (item data) {id, q}
						for item_data_key in item.keys():
							if typeof(item[item_data_key]) == TYPE_NIL:
								item_dict[item_data_key] = {'nullValue': null}
							elif typeof(item[item_data_key]) == TYPE_STRING:
								item_dict[item_data_key] = {'stringValue': item[item_data_key]}
							#int
							else:
								item_dict[item_data_key] = {'integerValue': item[item_data_key]} 
						item_shortcut[count] = {'mapValue':{'fields': item_dict}}
					else:
						item_shortcut[count] = {'nullValue': null}
					count += 1

	# keybinds
	shortcut = server_data["keybind"]
	fb_shortcut = firebase_data['keybind']['mapValue']['fields']
	for key in shortcut.keys():
		if shortcut[key] == null:
			fb_shortcut[key] = {"nullValue": null}
		else:
			fb_shortcut[key] = {"stringValue": shortcut[key]}
	
func save(var path : String, var thing_to_save: Dictionary):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(JSON.print(thing_to_save, "\t"))
	file.close()

func item_data_converter(before: Dictionary, after: Dictionary) -> Dictionary:
	for stat in before.keys():

		#if not stat in skip_list:
		if typeof(before[stat]) == TYPE_STRING:
			after[stat]["stringValue"] = before[stat]
		elif typeof(before[stat]) == TYPE_INT:
			after[stat]["integerValue"] = before[stat]
		elif typeof(before[stat]) == TYPE_NIL:
			after[stat]["nullValue"] = null
	return {'mapValue':{'fields': after}}
