extends PopupDialog

var item

func showBuyDialogue(i):
	item = i
	$CenterContainer/VBoxContainer/TextureRect.texture = load(item.texture)
	$CenterContainer/VBoxContainer/PriceLabel.text = Util.formatMoney(item.price)
	
	if item.price > GameManager.PlayerData.money:
		$CenterContainer/VBoxContainer/HBoxContainer/ButtonYes.disabled = true
		$CenterContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(1,0,0))
	else:
		$CenterContainer/VBoxContainer/HBoxContainer/ButtonYes.disabled = false
		$CenterContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0,1,0))
			
	
	popup_centered()

func _on_ButtonYes_pressed():
	GameManager.itemPurchase(item)
	$CenterContainer/VBoxContainer/MessageLabel.text = "Purchase successful"
	yield(get_tree().create_timer(0.8), "timeout")
	$CenterContainer/VBoxContainer/MessageLabel.text = ""
	GameManager.shopUpdateItems()
	hide()


func _on_ButtonNo_pressed():
	hide()
