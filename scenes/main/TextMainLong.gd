extends RichTextLabel

func updateUI(CurrentUi):
	if CurrentUi.has("TextLong"):
		show()
		#text = CurrentUi.TextLong
		parse_bbcode(CurrentUi.TextLong)
	else:
		hide()
