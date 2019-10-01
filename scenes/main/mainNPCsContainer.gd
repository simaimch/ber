extends MarginContainer

func updateUI(CurrentUi):
	if CurrentUi.ShowNPCs == true:
		show()
	else:
		hide()