extends PanelContainer

func updateUI(CurrentUi):
	if CurrentUi.get("ShowRL",true) == true:
		show()
	else:
		hide()
