extends Control

func updateUI(CurrentUi):
	if CurrentUi.ShowServices == true:
		show()
	else:
		hide()


func _on_BackButton_pressed():
	GameManager.servicesClose()
