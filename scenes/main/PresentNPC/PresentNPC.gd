extends Button

var npc
var id

func linkNpc():
	npc = GameManager.getNPC(id)

func setNPC(npcId):
	id = npcId
	linkNpc()
	text = GameManager.getNPCDescription(npc) +"\n"+ GameManager.getValue(npc,"name.first")+"\n"+str(Util.getAge(GameManager.now(),GameManager.getValue(npc,"bday")))
	

func _on_PresentNPC_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":text,"followMouse":true})


func _on_PresentNPC_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})


func _on_PresentNPC_pressed():
	get_tree().call_group("tooltip","hideTooltip",{})
	get_tree().call_group("gameCommand","npcDialog",npc)
