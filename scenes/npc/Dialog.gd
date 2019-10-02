extends Control

func updateUI(CurrentUi):
	if CurrentUi.ShowNPCDialog == true:
		show()
	else:
		hide()
