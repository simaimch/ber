extends LineEdit

var cmdHistory = []
var cmdHistoryIndex = -1

func history2Text():
	if cmdHistoryIndex == -1:
		text = ""
	else:
		text = cmdHistory[cmdHistoryIndex]

func _on_CommandLine_text_entered(new_text):
	GameManager.commandLine(text)
	
	if !cmdHistory.has(text):
		cmdHistory.push_front(text)
		#cmdHistory.pop_front()
	else:
		cmdHistory.erase(text)
		cmdHistory.push_front(text)
	cmdHistoryIndex = -1
	text = ""


func _on_CommandLine_gui_input(event):
	if event.is_action_pressed("ui_previous"):
		cmdHistoryIndex = min(cmdHistoryIndex+1,cmdHistory.size()-1)
		history2Text()
	elif event.is_action_pressed("ui_next"):
		cmdHistoryIndex = max(-1,cmdHistoryIndex-1)
		history2Text()
