extends TextureRect


func updateUI(CurrentUi):
	var item = GameManager.itemWornAtSlot("shoes")
	texture = Util.texture(item.texture)
