extends Control

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and GameManager.CurrentUi.get("ShowDetailsPC",false):
		GameManager.detailsHide()
		

func updateUI(CurrentUi):
	if CurrentUi.get("ShowDetailsPC",false) == true:
		show()
	else:
		hide()
