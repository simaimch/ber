extends Label

func updateUI(CurrentUi):
	if CurrentUi.ShowPlayerMoney == true:
		show()
		var money = CurrentUi.money
		text = Util.formatMoney(money)

	else:
		hide()