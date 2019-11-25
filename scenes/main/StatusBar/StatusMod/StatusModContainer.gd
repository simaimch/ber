extends Control

var StatusModPL = preload("res://scenes/main/StatusBar/StatusMod/StatusMod.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	var statusMods = GameManager.getValue(CurrentUi,"StatusMods",[])
	
	for statusMod in statusMods:
		var StautsModInstance = StatusModPL.instance()
		StautsModInstance.setMod(statusMod)
		add_child(StautsModInstance)