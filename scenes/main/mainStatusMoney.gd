extends Label

func updateUI(CurrentUi):
	if CurrentUi.get("ShowPlayerMoney",true) == true:
		show()
		#var money = CurrentUi.money
		var money = GameManager.PlayerData.money
		text = Util.formatMoney(money)

	else:
		hide()