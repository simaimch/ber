extends Button

var npc:NPC
var id:String
var tooltipText:String

#func linkNpc():
#	npc = GameManager.getNPC(id)

func setNPC(npcId:String):
	id = npcId
	npc = GameManager.npc(npcId)
#	linkNpc()
	
	#tooltipText = GameManager.getValueFromFunction("npcKnownName",npc)
	#$TextureRect.texture = Util.texture(GameManager.getValue(npc,"texture"))
	tooltipText = npc.knownName()
	$TextureRect.texture = npc.texture()

func _on_PresentNPC_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":tooltipText,"followMouse":true})
	pass


func _on_PresentNPC_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
	pass


func _on_PresentNPC_pressed():
	get_tree().call_group("tooltip","hideTooltip",{})
	GameManager.npcDetailsShow(npc)
	pass
