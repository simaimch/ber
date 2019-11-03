extends HBoxContainer

func setContent(statement):
	var npc = GameManager.getNPC(statement.charId)
	var npcName = GameManager.getValue(npc,"name.first")
	var npcTexture = GameManager.getValue(npc,"texture")
	var text = statement.text
	
	$VBoxContainer/CenterContainer/CharTexture.texture = Util.texture(npcTexture)
	$VBoxContainer/CenterContainer2/CharName.text = npcName
	$Statement.setText(text)
	