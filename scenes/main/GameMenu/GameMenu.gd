extends CanvasItem

func updateUI(CurrentUi):
	if CurrentUi.get("ShowGameMenu",false) == true:
		show()
	else:
		hide()

func _on_CancelButton_pressed():
	GameManager.gameMenuHide()


func _on_QuitButton_pressed():
	GameManager.QUIT()


func _on_FileDialog_file_selected(path):
	GameManager.gameMenuHide()
	GameManager.SaveGameSave(path)


func _on_SaveButton_pressed():
	$SaveGameDialog.popup_centered()


func _on_LoadGameDialog_file_selected(path):
	GameManager.loadGame(path)


func _on_LoadButton_pressed():
	$LoadGameDialog.popup_centered()
