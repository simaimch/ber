extends Button

var fileId

func set_cimage(id):
	if id == fileId:
		set("custom_colors/font_color",Color(0,1,0))
	else:
		set("custom_colors/font_color",Color(0,0,0))

func setItemFile(label, path, id):
	$TextureRect.texture = Util.texture(path)
	text = label
	fileId = id