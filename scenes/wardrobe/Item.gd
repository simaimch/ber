extends Button

var item

func setItem(i):
	item = i
	$HBoxContainer/TextureRect.texture = load(item.texture)
	$HBoxContainer/Label.text = item.ID

func _on_Item_pressed():
	GameManager.setItemWorn(item)
