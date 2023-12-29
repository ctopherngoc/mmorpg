extends Node

const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const DATABASE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID 
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
var user_info := {}
var httprequest = null
var server_token = ""

func _ready():
	pass

func _get_request_headers(token_id: String) -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % token_id
	])

# only when creating an account
# create baseline in /users and chreating new character in /characters
func save_document(path: String, fields: Dictionary, http: HTTPRequest, token: String)-> void:
	var document := {"fields": fields}
	var body := to_json(document)
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	if "users/" in path:
		http.request(url, _get_request_headers(token),false, HTTPClient.METHOD_POST, body)
		yield(http, "request_completed")
		#var result := yield(http, "request_completed") as Array
	else:
# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(token),false, HTTPClient.METHOD_POST, body)
		yield(http, "request_completed")

# because server controls database, requires user token as argument for get_request_header function
func get_document(path: String, http: HTTPRequest, token: String, player_container)-> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_GET)
	var result := yield(http, "request_completed") as Array
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	if result_body.has('fields'):
		if "users/" in path:
			if result_body["fields"]['characters']['arrayValue'].size() > 0:
				for i in result_body["fields"]['characters']['arrayValue']['values']:
					player_container.characters.append(i["stringValue"])
		elif "characters/" in path:
			# container = [player_id, char_dict, player_container, requester]
			firebase_dictionary_converter(result_body['fields'], player_container.characters_info_list)
	# documents search
	elif result_body.has('documents'):
		var document_list = result_body["documents"]
		var character_list = []
		for character in document_list:
			character_list.append(character['fields']['displayname']['stringValue'])

# saving characters/updating information
# creating new characters in /users
func update_document(path: String, http: HTTPRequest, token: String, player_container) -> void:
	"""
	path: user: playerContainer = array
	path: character: playerContainer = dictionary
	"""
	print("direct update fb from char")
	if 'users/' in path:
		# convert
		var character_array = []
		for character in player_container.characters:
			character_array.append({'stringValue':str(character)})
		var temp_dict = {'characters':{'arrayValue':{'values': character_array}}}
		var document := {"fields": temp_dict}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(http, "request_completed")
	else:
		# update /character
		var fb_data = ServerData.player_info.duplicate(true)
		server_dictionary_converter(player_container, fb_data)
		var document := {"fields": fb_data}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(http, "request_completed")

# calls only used by server
###############################################################################
func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	#return result_body.idToken
	return {
		"token" : result_body.idToken,
		"id" : result_body.localId,
		"timestamp" : OS.get_unix_time(),
	}

func login(email: String, password: String, http: HTTPRequest, results: Array):
	var body := {
		'email': email,
		'password': password,
		'returnSecureToken': true
	}
# warning-ignore:return_value_discarded
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array

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

func get_data(username, password):
	var results = []
	var firebaseStatus = login(username, password, httprequest, results)
	yield(firebaseStatus, "completed")
	if results[0] != 200:
		print("Server Signin Unsuccessful")
	else:
		print("Server Signin Successful")
		server_token = results[1]['token']
		var accounts_call = _server_get_document("users/", httprequest)
		yield(accounts_call, 'completed')
		var characters_call = _server_get_document("characters/", httprequest)
		yield(characters_call, 'completed')
		
func _server_get_document(path: String, http: HTTPRequest)-> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(server_token), false, HTTPClient.METHOD_GET)
	var result := yield(http, "request_completed") as Array
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	if "users" in path:
		var document_list = result_body["documents"]
		for document in document_list:
			var doc_id = document["name"].replace("projects/godotproject-ef224/databases/(default)/documents/users/", "")
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
				var character = document["name"].replace("projects/godotproject-ef224/databases/(default)/documents/characters/", "")
				ServerData.characters_data[character] = new_firebase_dictionary_converter(document["fields"])
		
# warning-ignore:unused_argument
func _server_update_document(http: HTTPRequest, array, action: String) -> void:
	print("server update fb")
	#path: user: playerContainer = array
	#path: character: playerContainer = dictionary
	if action == "server_user":
	#if 'users/' in path:
		# convert
		var user_dict = {}
		for user in ServerData.user_characters.keys():
			var character_array = []
			for character in ServerData.user_characters[user]:
				character_array.append({'stringValue':str(character)})
			user_dict[str(user)] = {"document": {"fields": {'characters':{'arrayValue':{'values': character_array}}}}}
		var body := to_json(user_dict)
		var url := DATABASE_URL + "/users"
		# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(server_token), false, HTTPClient.METHOD_PATCH, body)
		yield(http, "request_completed")
	else:
		for character in ServerData.username_list.keys():
			var fb_data = ServerData.player_info.duplicate(true)
			var ign: String = str(ServerData.username_list[character])
			server_dictionary_converter(Global.characters_data[ign], fb_data)
			var document := {"fields": fb_data}
			var body := to_json(document)
			var url := DATABASE_URL + "/characters/" + ign
			# warning-ignore:return_value_discarded
			http.request(url, _get_request_headers(server_token), false, HTTPClient.METHOD_PATCH, body)
			yield(http, "request_completed")
###############################################################################

# used only by server
func new_firebase_dictionary_converter(database_data: Dictionary):
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
			temp_dict['stats'][key][key2] = int(shortcut2[key2]['integerValue'])

	# avatar
	shortcut = database_data["avatar"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['avatar'] = {}
	for key in keys:
		# added situation if value saved as integervalue
		temp_dict['avatar'][key] = str(shortcut[key]['stringValue'])

	# equipment
	shortcut = database_data["equipment"]["mapValue"]["fields"] 
	keys = shortcut.keys()
	temp_dict['equipment'] = {}
	for key in keys:
		if 'integerValue' in shortcut[key].keys():
			temp_dict['equipment'][key] = int(shortcut[key]['integerValue'])
		else:
			temp_dict['equipment'][key] = {}
			var shortcut2 = shortcut[key]["mapValue"]["fields"]
			var keys2 = shortcut2.keys()
			for key2 in keys2:
				if 'integerValue' in shortcut2[key2]:
					temp_dict['equipment'][key][key2] = int(shortcut2[key2]['integerValue'])
				#elif 'stringValue' in shortcut2[key2]:
				else:
					temp_dict['equipment'][key][key2] = str(shortcut2[key2]['stringValue'])
#				else:
#					var shortcut3 = shortcut2[key2]["mapValue"]["fields"]
#					var keys3 = shortcut3.keys()
#					temp_dict['equipment'][key][key2] = {}
#					for key3 in keys3:
#						if 'integerValue'in shortcut3[key3]:
#							temp_dict['equipment'][key][key2][key3] = int(shortcut3[key3]['integerValue'])
#						elif 'stringValue'in shortcut3[key3]:
#							temp_dict['equipment'][key][key2][key3] = str(shortcut3[key3]['stringValue'])

	#inventory
	shortcut = database_data["inventory"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['inventory'] = {}
	for key in keys:
		if key == "gold":
			temp_dict['inventory'][key] = int(shortcut[key]['integerValue'])
		else:
			pass
	return temp_dict

# deleting a document will only occur if we are deleting a whole user account or deleting a character in /charaters
func delete_document(path: String, http: HTTPRequest, token: String) -> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_DELETE)
	yield(http, "request_completed")

func firebase_dictionary_converter(database_data: Dictionary, client_data: Array):
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
		"equipment": {}
		}
	for key in keys:
		var shortcut2 = shortcut[key]["mapValue"]["fields"]
		var keys2 = shortcut2.keys()
		for key2 in keys2:
			# added situation if value saved as integervalue
			temp_dict['stats'][key][key2] = int(shortcut2[key2]['integerValue'])
	# avatar
	shortcut = database_data["avatar"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['avatar'] = {}
	for key in keys:
		# added situation if value saved as integervalue
		temp_dict['avatar'][key] = shortcut[key]['stringValue']

	# equipment
	shortcut = database_data["equipment"]["mapValue"]["fields"] 
	keys = shortcut.keys()
	temp_dict['equipment'] = {}
	for key in keys:
		if 'integerValue' in shortcut[key].keys():
			temp_dict['equipment'][key] = shortcut[key]['integerValue']
		else:
			temp_dict['equipment'][key] = {}
			var shortcut2 = shortcut[key]["mapValue"]["fields"]
			var keys2 = shortcut2.keys()
			for key2 in keys2:
				if 'integerValue' in shortcut2[key2]:
					temp_dict['equipment'][key][key2] = shortcut2[key2]['integerValue']
				#elif 'stringValue' in shortcut2[key2]:
				else:
					temp_dict['equipment'][key][key2] = shortcut2[key2]['stringValue']
#				else:
#					var shortcut3 = shortcut2[key2]["mapValue"]["fields"]
#					var keys3 = shortcut3.keys()
#					temp_dict['equipment'][key][key2] = {}
#					for key3 in keys3:
#						if 'integerValue'in shortcut3[key3]:
#							temp_dict['equipment'][key][key2][key3] = shortcut3[key3]['integerValue']
#						elif 'stringValue'in shortcut3[key3]:
#							temp_dict['equipment'][key][key2][key3] = shortcut3[key3]['stringValue']

	#inventory
	shortcut = database_data["inventory"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['inventory'] = {}
	for key in keys:
		if key == "gold":
			temp_dict['inventory'][key] = shortcut[key]['integerValue']
		else:
			pass
	
	client_data.append(temp_dict)

func server_dictionary_converter(server_data: Dictionary, firebase_data: Dictionary):
	"""
	currently takes singular character information dictionary and converts to firebase dictionary
	must loop for whole account to be saved
	in: server dictionary
	out: firebase dictionary
	"""
	# displayname and position
	firebase_data['displayname']['stringValue'] = str(server_data["displayname"])
	firebase_data['map']['integerValue'] = int(server_data["map"])

	# stats
	var shortcut = server_data["stats"]
	var keys = shortcut.keys()
	var fb_shortcut = firebase_data['stats']['mapValue']['fields']
	# base, equipment
	for key in keys:
		var shortcut_keys2 = shortcut[key].keys()
		# stats
		for key2 in shortcut_keys2:
			fb_shortcut[key]['mapValue']['fields'][key2]['integerValue'] = int(shortcut[key][key2])
	
	# avatar
	shortcut = server_data["avatar"]
	keys = shortcut.keys()
	fb_shortcut = firebase_data['avatar']['mapValue']['fields']
	for key in keys:
		fb_shortcut[key]['stringValue'] = str(shortcut[key])
	
	# equipment
	shortcut = server_data["equipment"]
	keys = shortcut.keys()
	fb_shortcut = firebase_data['equipment']['mapValue']['fields']
	for key in keys:
		# non implement gear are integers
		if shortcut[key] is int:
			fb_shortcut[key]['integerValue'] = int(shortcut[key])
		# currently rweapon
		else:
			# weapon dict
			var temp_dict = ServerData.equipment_data_template.duplicate(true)
			# [equipment][rweapon]
			var shortcut2 = shortcut[key]
			var keys2 = shortcut2.keys()
			
			# rweapon dict
			for key2 in keys2:
				if key2 in ["name", "type"]:
					temp_dict[key2] = {'stringValue' : shortcut2[key2]}
				else:
					temp_dict[key2] = {'integerValue': shortcut2[key2]}
				# rweapon[stats]
#				else:
#					#key2 == stats
#					temp_dict[key2] = {'mapValue' : {'fields' : {}}}
#					var shortcut3 = shortcut2[key2]
#					var keys3 = shortcut3.keys()
#					for key3 in keys3:
#						temp_dict[key2]['mapValue']['fields'][key3] ={'integerValue' : shortcut3[key3]}
			fb_shortcut[key] = {'mapValue':{'fields': temp_dict}}
			print(fb_shortcut[key])

	#inventory
	shortcut = server_data["inventory"]
	keys = shortcut.keys()
	fb_shortcut = firebase_data['inventory']['mapValue']['fields']
	for key in keys:
		if key == "gold":
			fb_shortcut[key]['integerValue'] = int(shortcut[key])
		else:
			pass
