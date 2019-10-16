extends Button

func setService(service):
	$HBoxContainer/Label.text = service.description
	$HBoxContainer/TextureRect.texture = Util.texture(service.texture)