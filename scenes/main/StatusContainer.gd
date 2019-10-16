extends HBoxContainer


func _on_StatusContainer_mouse_entered():
	GameManager.CurrentUi.ShowStatusDetails = true
	GameManager.updateUI()

func _on_StatusContainer_mouse_exited():
	GameManager.CurrentUi.ShowStatusDetails = false
	GameManager.updateUI()
