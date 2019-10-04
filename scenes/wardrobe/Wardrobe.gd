extends Control

func updateUI(CurrentUi):
	if CurrentUi.ShowWardrobe == true:
		show()
	else:
		hide()


func _on_BackButton_pressed():
	GameManager.wardrobeClose()
