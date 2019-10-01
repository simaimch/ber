extends Button

var npc;


func setNPC(n):
	npc = n
	text = GameManager.getValue(npc,"name.first")+"\n"+str(Util.getAge(GameManager.now(),GameManager.getValue(npc,"bday")))
	

func _on_PresentNPC_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":text,"followMouse":true})


func _on_PresentNPC_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
