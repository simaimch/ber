extends Control

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and GameManager.CurrentUi.ShowDetailsPC:
		GameManager.detailsHide()
		

func updateUI(CurrentUi):
	if CurrentUi.ShowDetailsPC == true:
		show()
	else:
		hide()
