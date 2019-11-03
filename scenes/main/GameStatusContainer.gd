extends PanelContainer

func updateUI(CurrentUi):
	if CurrentUi.get("ShowGameStatus",false) == true:
		show()
	else:
		hide()
