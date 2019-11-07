extends LineEdit

func _on_CommandLine_text_entered(new_text):
	GameManager.commandLine(text)
	text = ""
