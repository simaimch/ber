extends VBoxContainer

var actionPL = preload("res://scenes/main/ActionButton/ActionButton.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for action in GameManager.CurrentUi.Actions:
		var actionInstance = actionPL.instance()
		actionInstance.setAction(action)
		add_child(actionInstance)
