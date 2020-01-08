extends AcceptDialog

func showError(p):
	window_title = p.get("title","ERROR")
	dialog_text = p.get("msg","Message missing")
	popup_centered()
