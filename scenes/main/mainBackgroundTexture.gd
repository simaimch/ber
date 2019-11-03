extends TextureRect

func updateUI(CurrentUi):
	var bgTexture = Util.texture(CurrentUi.Bg)
	set_texture(bgTexture)
