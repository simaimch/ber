extends Button

var serviceId = ""

func setService(service):
	disabled = false
	serviceId = service.ID
	
	if service.has("name"):
		$HBoxContainer/VBoxContainer/NameLabel.text = service.name
	elif service.has("description"):
		$HBoxContainer/VBoxContainer/NameLabel.text = service.description
	else:
		$HBoxContainer/VBoxContainer/NameLabel.text = "Name missing"
		
	
	if service.has("description"):
		$HBoxContainer/VBoxContainer/DescriptionLabel.text = service.description
		$HBoxContainer/VBoxContainer/DescriptionLabel.show()
	else:
		$HBoxContainer/VBoxContainer/DescriptionLabel.hide()
	
	
	if service.get("price",0) > 0:
		$HBoxContainer/VBoxContainer/PriceLabel.text = Util.formatMoney(service.price)
		$HBoxContainer/VBoxContainer/PriceLabel.show()
		if service.price > GameManager.PlayerData.money:
			$HBoxContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0.8,0,0))
			disabled = true
		else:
			$HBoxContainer/VBoxContainer/PriceLabel.set("custom_colors/font_color",Color(0,0.8,0))
	else:
		$HBoxContainer/VBoxContainer/PriceLabel.hide()
		
	if service.get("time",0) > 0:
		$HBoxContainer/VBoxContainer/TimeLabel.text = Util.formatTimeHHMMSS(service.time)
		$HBoxContainer/VBoxContainer/TimeLabel.show()
	else:
		$HBoxContainer/VBoxContainer/TimeLabel.hide()
		
	if service.has("availableCountRef"):
		var availableCount = GameManager.getValueFromPath(service.availableCountRef,0)
		$HBoxContainer/VBoxContainer/UsesleftLabel.show()
		if availableCount > 0:
			if availableCount > 1:
				$HBoxContainer/VBoxContainer/UsesleftLabel.text = str(availableCount)+" uses left"
			else:
				$HBoxContainer/VBoxContainer/UsesleftLabel.text = "1 use left"
			$HBoxContainer/VBoxContainer/UsesleftLabel.set("custom_colors/font_color",Color(0,0,0))
		else:
			$HBoxContainer/VBoxContainer/UsesleftLabel.text = "0 uses left"
			$HBoxContainer/VBoxContainer/UsesleftLabel.set("custom_colors/font_color",Color(0.8,0,0))
			disabled = true
		if service.has("availableCountHint"):
			$HBoxContainer/VBoxContainer/UsesleftLabel.text += " ("+service.availableCountHint+")"
	elif service.has("increaseRef"):
		var availableCount = GameManager.getValueFromPath(service.increaseRef,0)
		$HBoxContainer/VBoxContainer/UsesleftLabel.text = "You have "+str(availableCount)
		$HBoxContainer/VBoxContainer/UsesleftLabel.set("custom_colors/font_color",Color(0,0,0))
	else:
		$HBoxContainer/VBoxContainer/UsesleftLabel.hide()
		
	$HBoxContainer/TextureRect.texture = Util.texture(service.texture)

func _on_Service_pressed():
	GameManager.serviceBuy(serviceId)
