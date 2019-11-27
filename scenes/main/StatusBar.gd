extends Control

func updateUI(CurrentUi):
	if CurrentUi.get("ShowStatusBar",true) == true:
		show()
	else:
		hide()