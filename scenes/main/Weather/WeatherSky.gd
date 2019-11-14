extends Label

func updateUI(CurrentUi):
	var sky = GameManager.getValue(GameManager.WorldData,"weather.sky","")
	text = sky
