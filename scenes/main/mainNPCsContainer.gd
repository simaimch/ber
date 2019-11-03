extends PanelContainer

func updateUI(CurrentUi):
	if CurrentUi.get("ShowNPCs",true) == true:
		show()
	else:
		hide()