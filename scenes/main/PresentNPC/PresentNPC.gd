extends Button

var npc:Dictionary
var id:String
var tooltipText:String

func linkNpc():
	npc = GameManager.getNPC(id)

func setNPC(npcId:String):
	id = npcId
	linkNpc()
	tooltipText = GameManager.getValueFromFunction("npcKnownName",npc)
	$TextureRect.texture = Util.texture(GameManager.getValue(npc,"texture"))

func _on_PresentNPC_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":tooltipText,"followMouse":true})


func _on_PresentNPC_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})


func _on_PresentNPC_pressed():
	get_tree().call_group("tooltip","hideTooltip",{})
	#get_tree().call_group("gameCommand","npcDialog",npc)
	GameManager.npcDetailsShow(npc)
