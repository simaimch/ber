extends VBoxContainer

var actionPL = preload("res://scenes/main/ActionButton/ActionButton.tscn")
	

func clearChildren():
	for i in get_children():
		i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	var i = 1
	
	for action in CurrentUi.Actions:
		var actionInstance = actionPL.instance()
		
		if i < 10: 
			actionInstance.setAction(action,i)
			i += 1
		elif i == 10: 
			actionInstance.setAction(action,0)
			i += 1
		else: 
			actionInstance.setAction(action)
		add_child(actionInstance)
