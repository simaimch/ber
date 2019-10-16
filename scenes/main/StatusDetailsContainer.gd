extends MarginContainer

func updateUI(CurrentUi):
	if CurrentUi.ShowStatusDetails == true:
		show()
	else:
		hide()
