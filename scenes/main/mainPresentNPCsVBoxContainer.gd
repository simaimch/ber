extends VBoxContainer

var presentNPCPL = preload("res://scenes/main/PresentNPC/PresentNPC.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for npc in GameManager.CurrentUi.NPCs:
		var presentNPCInstance = presentNPCPL.instance()
		presentNPCInstance.setNPC(npc)
		add_child(presentNPCInstance)