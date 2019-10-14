extends TextureRect

func updateUI(CurrentUi):
	var item = GameManager.itemWornAtSlot("clothes")
	texture = Util.texture(item.texture)
