extends PanelContainer

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and GameManager.CurrentUi.get("ShowNPCGroup",false):
		GameManager.npcGroupHide()

func updateUI(CurrentUi):
	if CurrentUi.get("ShowNPCGroup",false) == true:
		show()
	else:
		hide()