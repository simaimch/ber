extends PanelContainer

func updateUI(CurrentUi):
	if CurrentUi.ShowNPCs == true:
		show()
	else:
		hide()