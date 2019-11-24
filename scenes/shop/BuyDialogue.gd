extends PopupDialog

var item

func showBuyDialogue(i):
	item = i
	$CenterContainer/VBoxContainer/ItemInfoContainer/TextureRect.texture = Util.texture(item.texture)
	
	$CenterContainer/VBoxContainer/ItemInfoContainer/DescriptionLabel.text = GameManager.getValueFromFunction("itemDescriptionWear",[item,GameManager.PlayerData])
	
	$CenterContainer/VBoxContainer/PriceLabel.text = Util.formatMoney(item.price)
	
	var buyButtonDisabled = false
	
	if item.price > GameManager.PlayerData.money:
		#$CenterContainer/VBoxContainer/HBoxContainer/ButtonYes.disabled = true
		$CenterContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(1,0,0))
		$CenterContainer/VBoxContainer/ErrorPriceTooHigh.show()
		buyButtonDisabled = true
	else:
		#$CenterContainer/VBoxContainer/HBoxContainer/ButtonYes.disabled = false
		$CenterContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0,1,0))
		$CenterContainer/VBoxContainer/ErrorPriceTooHigh.hide()
	
	if GameManager.PlayerData.inventory.has(item.ID):
		$CenterContainer/VBoxContainer/ErrorOwned.show()
		buyButtonDisabled = true
	else:
		$CenterContainer/VBoxContainer/ErrorOwned.hide()
	
	$CenterContainer/VBoxContainer/HBoxContainer/ButtonYes.disabled = buyButtonDisabled
		
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
