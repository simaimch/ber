extends VBoxContainer

var statementPL = preload("res://scenes/npc/DialogStatement.tscn")

func clearChildren():
	for i in get_children():
		i.queue_free()
		

func updateUI(CurrentUi):
	clearChildren()
	
	if CurrentUi.NPCDialog.size() == 0: return
	
	var currentChar = ""
	var currentText = ""
	
	for statement in CurrentUi.NPCDialog:
		var charId = statement.charId
		if currentChar == "":
			currentChar = charId
			currentText = statement.text
		elif charId == currentChar:
			currentText += "\n\n"+statement.text
		else:
			var statementInstance = statementPL.instance()
			var newStatement = {"charId":currentChar,"text":currentText}
			statementInstance.setContent(newStatement)
			add_child(statementInstance)
			currentChar = charId
			currentText = statement.text
			
	var statementInstance = statementPL.instance()
	var newStatement = {"charId":currentChar,"text":currentText}
	statementInstance.setContent(newStatement)
	add_child(statementInstance)
	#scrollToEnd()
	
