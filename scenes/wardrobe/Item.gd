extends Button

var item

func setItem(i):
	item = i
	$HBoxContainer/TextureRect.texture = Util.texture(item.texture)
	$HBoxContainer/VBoxContainer/NameLabel.text = item.ID
	$HBoxContainer/VBoxContainer/DescriptionLabel.text = GameManager.getValueFromFunction("itemDescriptionWear",[item,GameManager.PlayerData])
	
func _on_Item_pressed():
	GameManager.setItemWorn(item)
