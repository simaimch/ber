extends Button

func setHeight(h):
	var textureSize = $Texture.texture.get_size()
	var w = h * textureSize.x / textureSize.y
	
	rect_size.x = w
	rect_size.y = h
	
	$Texture.rect_size.x = w
	$Texture.rect_size.y = h
	
func setTexture(t):
	$Texture.texture = t
	setHeight(rect_size.y)