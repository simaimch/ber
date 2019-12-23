extends CenterContainer

func setNPC(npcId:String):
	var npc = GameManager.getNPC(npcId)
	var npcName = GameManager.getValueFromFunction("npcName",npc)
	#$VBoxContainer/Label.text = GameManager.getValueFromFunction("npcKnownName",npc)
	$VBoxContainer/Label.text = npcName
	$VBoxContainer/TextureRect.texture = Util.texture(GameManager.getValue(npc,"texture",""))