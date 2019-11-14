extends Control

func updateUI(CurrentUi):
	var timeOfDay = GameManager.getValueFromPath("WorldData.weather.timeOfDay")
	
	if timeOfDay == "dusk1":
		theme = preload("res://themes/time/dusk/dusk.tres")