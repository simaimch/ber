extends Button

var npc
var id
var tooltipText

func linkNpc():
	npc = GameManager.getNPC(id)

func setNPC(npcId):
	id = npcId
	linkNpc()
	tooltipText = GameManager.getNPCDescription(npc) +"\n"+ GameManager.getValue(npc,"name.first")+"\n"+str(Util.getAge(GameManager.now(),GameManager.getValue(npc,"bday")))
	$TextureRect.texture = load(GameManager.getValue(npc,"texture"))

func _on_PresentNPC_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":tooltipText,"followMouse":true})


func _on_PresentNPC_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})


func _on_PresentNPC_pressed():
	get_tree().call_group("tooltip","hideTooltip",{})
	get_tree().call_group("gameCommand","npcDialog",npc)
