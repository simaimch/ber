extends TextureButton

export var Number:String

func setColor(c):
	if c == null:
		$ColorRect.color = Color(0,0,0,0)
	else:
		$ColorRect.color = Color(c)

func setTexture(t):
	texture_normal = t
	
func setLabel(s:String):
	if s.empty():
		$CenterContainer/Label.hide()
	else:
		$CenterContainer/Label.show()
		$CenterContainer/Label.text = s