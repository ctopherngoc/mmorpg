extends Node

onready var httprequest
const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const DATABASE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID 


var user_info := {}

func _get_request_headers(token: String) -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % token
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
func get_document(path: String, http: HTTPRequest, token: String, playerContainer)-> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_GET)
	var result := yield(http, "request_completed") as Array
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	if result_body.has('fields'):
		if "users/" in path:
			if result_body["fields"]['characters']['arrayValue'].size() > 0:
				for i in result_body["fields"]['characters']['arrayValue']['values']:
					playerContainer.characters.append(i["stringValue"])
		elif "characters/" in path:
			FirebaseDictConverter(result_body['fields'], playerContainer.characters_info_list)
	# documents search
	elif result_body.has('documents'):
		var doc_list = result_body["documents"]
		var charList = []
		for character in doc_list:
			charList.append(character['fields']['displayname']['stringValue'])
		ServerData.username_list = charList.duplicate()

# saving characters/updating information
# creating new characters in /users
func update_document(path: String, http: HTTPRequest, token: String, playerContainer) -> void:
	"""
	path: user: playerContainer = array
	path: character: playerContainer = dictionary
	"""
	if 'users/' in path:
		# convert
		var array = []
		for character in playerContainer.characters:
			array.append({'stringValue':str(character)})
		var temp_dict = {'characters':{'arrayValue':{'values': array}}}
		var document := {"fields": temp_dict}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(http, "request_completed")
	else:
		# update /character
		var fb_data = ServerData.playerInfo.duplicate()
		ServerDictConverter(playerContainer, fb_data)
		var document := {"fields": fb_data}
		var body := to_json(document)
		var url := DATABASE_URL + path
		# warning-ignore:return_value_discarded
		http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_PATCH, body)
		yield(http, "request_completed")

# deleting a document will only occur if we are deleting a whole user account	
# or deleting a character in /charaters
func delete_document(path: String, http: HTTPRequest, token: String) -> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(token), false, HTTPClient.METHOD_DELETE)
	yield(http, "request_completed")
	
func FirebaseDictConverter(database_data: Dictionary, client_data: Array):
	"""
	takes firebase json dictionary converts to normal dictionary and appends to an array
	"""
	var temp_dict = {}
	
	# displayname and position
	temp_dict['displayname'] = database_data["displayname"]['stringValue']
	temp_dict['lastmap'] = database_data["lastmap"]['stringValue']
	temp_dict['position'] = database_data["position"]['doubleValue']
	
	# stats
	var shortcut = database_data["stats"]["mapValue"]["fields"]
	var keys = shortcut.keys()
	temp_dict['stats'] = {}
	for key in keys:
		temp_dict['stats'][key] = shortcut[key]['doubleValue']
	
	
	# equipment
	shortcut = database_data["equipment"]["mapValue"]["fields"] 
	keys = shortcut.keys()
	temp_dict['equipment'] = {}
	for key in keys:
		temp_dict['equipment'][key] = shortcut[key]['doubleValue']
	
	#inventory
	shortcut = database_data["inventory"]["mapValue"]["fields"]
	keys = shortcut.keys()
	temp_dict['inventory'] = {}
	for key in keys:
		if key == "money":
			temp_dict['inventory'][key] = shortcut[key]['doubleValue']
		else:
			pass
	
	client_data.append(temp_dict)

func ServerDictConverter(server_data: Dictionary, firebase_data: Dictionary):
	"""
	currently takes singular character information dictionary and converts to firebase dictionary
	must loop for whole account to be saved
	in: server dictionary
	out: firebase dictionary
	"""
	# displayname and position
	firebase_data['displayname']['stringValue'] = server_data["displayname"]
	firebase_data['lastmap']['stringValue'] = server_data["lastmap"]
	firebase_data['position']['doubleValue'] = server_data["position"]

	# stats
	var shortcut = server_data["stats"]
	var keys = shortcut.keys()
	var fb_shortcut = firebase_data['stats']['mapValue']['fields']
	#var client_stats = temp_dict['stats']
	for key in keys:
		fb_shortcut[key]['doubleValue'] = shortcut[key]
		
	# equipment
	shortcut = server_data["equipment"]
	keys = shortcut.keys()
	fb_shortcut = firebase_data['equipment']['mapValue']['fields']
	for key in keys:
		fb_shortcut[key]['doubleValue'] = shortcut[key]

	#inventory
	shortcut = server_data["inventory"]
	keys = shortcut.keys()
	fb_shortcut = firebase_data['inventory']['mapValue']['fields']
	for key in keys:
		if key == "money":
			fb_shortcut[key]['doubleValue'] = shortcut[key]
		else:
			pass
