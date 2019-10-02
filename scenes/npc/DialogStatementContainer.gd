extends VBoxContainer

var statementPL = preload("res://scenes/npc/DialogStatement.tscn")

func clearChildren():
	for i in get_children():
    	i.queue_free()
		

#func scrollToEnd():
	#var tree = get_tree()
	#if tree==null:return
	#yield(tree, "idle_frame")
	#get_parent().scroll_vertical = 10000000000#get_parent().get_v_scrollbar().max_value
	#get_parent().get_v_scrollbar().allow_greater = true
	#get_parent().set_v_scroll(rect_size.y)
	#print(get_parent().scroll_vertical)
	#print(get_parent().get_v_scrollbar().max_value)

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
	
