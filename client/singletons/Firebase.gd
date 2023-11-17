extends Node
#inactive
#kept for reference

const API_KEY := "AIzaSyC2PkBqVa6lm9zG7gfy7MLZvNpRytA8klU"
const PROJECT_ID := "godotproject-ef224"
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
const DATABASE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID 
#var current_token := ""

var user_info := {}

#func _get_token_id_from_result(result: Array) -> String:
func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	#return result_body.idToken
	return {
		"token" : result_body.idToken,
		"id" : result_body.localId
	}

func _get_request_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_info.token
	])
	
func register(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		'email': email,
		'password': password,
	}
	
# warning-ignore:return_value_discarded
	http.request(REGISTER_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)
		#current_token = _get_token_id_from_result(result)
		
func login(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		'email': email,
		'password': password,
		'returnSecureToken': true
	}
	
# warning-ignore:return_value_discarded
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		user_info = _get_user_info(result)
		#current_token = _get_token_id_from_result(result)
	
func save_document(path: String, fields: Dictionary, http: HTTPRequest)-> void:
	var document := {"fields": fields}
	var body := to_json(document)
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(),false, HTTPClient.METHOD_POST, body)
	
func get_document(path:String, http: HTTPRequest) -> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)
	var result := yield(http, "request_completed") as Array
	if result[1] == 200:
		var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
		print(result_body['fields'])

func update_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := {"fields": fields}
	var body := to_json(document)
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)
	
func delete_document(path: String, http: HTTPRequest) -> void:
	var url := DATABASE_URL + path
# warning-ignore:return_value_discarded
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)
	
