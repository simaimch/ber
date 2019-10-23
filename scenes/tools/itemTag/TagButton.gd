extends TextureButton

export var Number:String

func setTexture(t):
	texture_normal = t
	
func setLabel(s:String):
	if s.empty():
		$CenterContainer/Label.hide()
	else:
		$CenterContainer/Label.show()
		$CenterContainer/Label.text = s