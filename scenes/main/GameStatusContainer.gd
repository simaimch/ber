extends PanelContainer

func updateUI(CurrentUi):
	if CurrentUi.ShowGameStatus == true:
		show()
	else:
		hide()
