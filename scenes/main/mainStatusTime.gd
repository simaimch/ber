extends Label

func updateUI(CurrentUi):
	if CurrentUi.get("ShowTime",true) == true:
		show()
		text = Util.formtTime(GameManager.now(),"{weekday}, {day}.{month}.{year} {hour}:{minute}")
	else:
		hide()
		
