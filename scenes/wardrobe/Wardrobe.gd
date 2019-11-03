extends Control

func updateUI(CurrentUi):
	if CurrentUi.get("ShowWardrobe",false) == true:
		show()
	else:
		hide()


func _on_BackButton_pressed():
	GameManager.wardrobeClose()
