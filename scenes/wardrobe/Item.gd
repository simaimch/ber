extends Button

var item

func setItem(i):
	item = i
	$HBoxContainer/TextureRect.texture = load(item.texture)
	$HBoxContainer/Label.text = item.ID + "\n" + GameManager.getValueFromFunction("shoeDescription",item) + "\n"+str(GameManager.getValueFromFunction("shoeDifficultyDiscriptionPC",item))

func _on_Item_pressed():
	GameManager.setItemWorn(item)
