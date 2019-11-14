extends Label

func updateUI(CurrentUi):
	var temperature = GameManager.getValue(GameManager.WorldData,"weather.temperature",10)
	text = str(temperature)+"°C"