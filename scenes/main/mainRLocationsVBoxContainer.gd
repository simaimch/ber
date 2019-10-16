extends VBoxContainer

var rlocationPL = preload("res://scenes/main/RLocation/RLocation.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for rl in CurrentUi.RL:
		var rlInstance = rlocationPL.instance()
		rlInstance.setLocation(rl)
		add_child(rlInstance)
