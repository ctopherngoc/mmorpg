extends TextureRect

onready var skill_icon = $HBoxContainer/NinePatchRect/Icon
onready var skill_name = $HBoxContainer/VBoxContainer/HBoxContainer/Label
onready var skill_level = $HBoxContainer/VBoxContainer/HBoxContainer2/Label2

var skill_data = {"id": null,
				"name": null,
				"level": null}

func _ready():
	pass


func _on_Button_pressed():
	pass # Replace with function body.
	
func _on_Icon_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
				AudioControl.play_audio("menuClick")

func to_gray_scale(texture):
	var image: = Image.new()
	image = texture.get_data()
	image.lock()
	for x in texture.get_size().x:
		for y in texture.get_size().y:
			var current_pixel = image.get_pixel(x,y)
			if current_pixel.a == 1:
				current_pixel = current_pixel.gray()
				var new_color = Color.from_hsv(0, 0, current_pixel)
				image.set_pixel(x, y, new_color)
	image.unlock()
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	return image_texture
	
