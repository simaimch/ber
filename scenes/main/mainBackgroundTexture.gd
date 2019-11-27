extends TextureRect

func updateUI(CurrentUi):
	
	if CurrentUi.Bg:
		var bgTexture = Util.texture(CurrentUi.Bg)
		show()
		set_texture(bgTexture)
	else:
		hide()
