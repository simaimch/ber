extends MarginContainer

func updateUI(CurrentUi):
	if CurrentUi.get("ShowStatusDetails",false) == true:
		show()
	else:
		hide()
