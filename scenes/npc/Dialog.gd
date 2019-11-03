extends Control

func updateUI(CurrentUi):
	if CurrentUi.get("ShowNPCDialog",false) == true:
		show()
	else:
		hide()
