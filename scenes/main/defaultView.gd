extends Control

func updateUI(CurrentUi):
	#var timeOfDay = GameManager.getValueFromPath("WorldData.weather.timeOfDay","night")
	
	#theme = GameManager.getTheme(timeOfDay)
	theme = GameManager.getCurrentTheme()
