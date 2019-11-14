extends Control

func updateUI(CurrentUi):
	var timeOfDay = GameManager.getValueFromPath("WorldData.weather.timeOfDay")
	
	theme = GameManager.getTheme(timeOfDay)