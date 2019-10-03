extends Control

func updateUI(CurrentUi):
	if CurrentUi.ShowShop == true:
		show()
	else:
		hide()