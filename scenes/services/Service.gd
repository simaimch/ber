extends Button

var serviceId = ""

func setService(service):
	serviceId = service.ID
	
	$HBoxContainer/VBoxContainer/NameLabel.text = service.description
	
	if service.has("price"):
		$HBoxContainer/VBoxContainer/PriceLabel.text = Util.formatMoney(service.price)
		$HBoxContainer/VBoxContainer/PriceLabel.show()
		if service.price > GameManager.PlayerData.money:
			$HBoxContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0.8,0,0))
		else:
			$HBoxContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0,0.8,0))
	else:
		$HBoxContainer/VBoxContainer/PriceLabel.hide()
		
	if service.has("time"):
		$HBoxContainer/VBoxContainer/TimeLabel.text = Util.formatTimeHHMMSS(service.time)
		$HBoxContainer/VBoxContainer/TimeLabel.show()
	else:
		$HBoxContainer/VBoxContainer/TimeLabel.hide()
		
	$HBoxContainer/TextureRect.texture = Util.texture(service.texture)

func _on_Service_pressed():
	GameManager.serviceBuy(serviceId)
