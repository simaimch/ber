extends WindowDialog

func dialogClose(arg):
	hide()
	
func dialogError(msg):
	$CenterContainer/VBoxContainer/ErrorMsg.show()
	$CenterContainer/VBoxContainer/ErrorMsg.text = msg

func showDialog(label):
	$CenterContainer/VBoxContainer/HBoxContainer/Label.text = label
	$CenterContainer/VBoxContainer/ErrorMsg.hide()
	popup_centered()

func _on_ButtonOkay_pressed():
	var value = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit.text
	get_tree().call_group("inputDialogResult","inputResult",value)
