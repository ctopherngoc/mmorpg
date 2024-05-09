extends Node

const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
const DATABASE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID 
var auth_token = ""
onready var username = "auth@server.com"
onready var password = "authserver"
onready var account_id_list = []
onready var fb_http

func _ready():
	pass

#func _get_token_id_from_result(result: Array) -> String:
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
	
	print("login %s" % body)
	
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

func auth_get_token():
	var results = []
	var firebaseStatus = login(username, password, fb_http, results)
	yield(firebaseStatus, "completed")
	if results[0] != 200:
		print("auth Signin Unsuccessful")
	else:
		print("auth Signin Successful")
		auth_token = results[1]['token']
		_server_get_document("users", fb_http)
		
func _get_request_headers(token_id: String) -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % token_id
	])

func _server_get_document(path: String, http: HTTPRequest)-> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(auth_token), false, HTTPClient.METHOD_GET)
	var result := yield(http, "request_completed") as Array
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	#print(result_body)
	var document_list = result_body["documents"]
	for document in document_list:
		var doc_id = document["name"].replace("projects/godotproject-ef224/databases/(default)/documents/users/", "")
		if not account_id_list.has(str(doc_id)):
			account_id_list.append(str(doc_id))
			
func update_document(path: String) -> void:
	var character_list = {"fields": {'characters':{'arrayValue':{'values': []}}}}
	var body := to_json(character_list)
	var url := DATABASE_URL + path
	print(body)
	# warning-ignore:return_value_discarded
	fb_http.request(url, _get_request_headers(auth_token), false, HTTPClient.METHOD_PATCH, body)
	yield(fb_http, "request_completed")

