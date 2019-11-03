extends Control

func updateUI(CurrentUi):
	if CurrentUi.get("ShowShop",false) == true:
		show()
	else:
		hide()