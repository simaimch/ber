extends Label

func updateUI(CurrentUi):
	if CurrentUi.ShowTime == true:
		show()
		text = Util.formtTime(GameManager.now())
	else:
		hide()
		
