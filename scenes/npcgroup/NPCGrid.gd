extends GridContainer

var npcPL = preload("res://scenes/npcgroup/NPC.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	var i = 1
	
	var NPCGroupNPCIds = CurrentUi.get("NPCGroupNPCIds",[])
	
	for npcId in NPCGroupNPCIds:
		var npcInstance = npcPL.instance()
		npcInstance.setNPC(npcId)
		add_child(npcInstance)