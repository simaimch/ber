extends HBoxContainer

func setContent(statement):
	if statement.charId == "NARRATOR":
		$Statement.set("custom_colors/default_color",Color(0.7,0.7,0.7))
		$VBoxContainer/CenterContainer/CharTexture.hide()
		$VBoxContainer/CenterContainer2/CharName.hide()
	else:
		var npc = GameManager.getNPC(statement.charId)
		var npcName = GameManager.getValue(npc,"name.first")
		var npcTexture = GameManager.getValue(npc,"texture","")
		$VBoxContainer/CenterContainer/CharTexture.texture = Util.texture(npcTexture)
		$VBoxContainer/CenterContainer2/CharName.text = npcName
	var text = statement.text
	
	
	
	$Statement.setText(text)
	
