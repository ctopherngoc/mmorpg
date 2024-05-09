extends Node

func _ready():
	Authenticate.http = $HTTPRequest
	Firebase.fb_http = $HTTPRequest2
	Firebase.auth_get_token()
