extends Node

const API_KEY := ""
const PROJECT_ID := ""
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY

#func _get_token_id_from_result(result: Array) -> String:
func _get_user_info(result: Array) -> Dictionary:
	var test_json_conv = JSON.new()
	test_json_conv.parse(result[3].get_string_from_ascii()).result as Dictionary
	var result_body := test_json_conv.get_data()
	#return result_body.idToken
	return {
		"token" : result_body.idToken,
		"id" : result_body.localId,
		"timestamp" : Time.get_unix_time_from_system(),
	}
		
func login(email: String, password: String, http: HTTPRequest, results: Array):
	var body := {
		'email': email,
		'password': password,
		'returnSecureToken': true
	}
	
	print("login %s" % body)
	
# warning-ignore:return_value_discarded
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, JSON.new().stringify(body))
	var result := await http.request_completed as Array

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
