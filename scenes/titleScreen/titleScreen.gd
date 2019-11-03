extends Control

func _on_ContinueButton_pressed():
	return get_tree().change_scene("res://scenes/continueGameScreen/continueGameScreen.tscn")


func _on_NewGameButton_pressed():
	return get_tree().change_scene("res://scenes/newGameScreen/newGameScene.tscn")


func _on_QuitButton_pressed():
	GameManager.QUIT()



func _on_Tools_pressed():
	#$MarginContainer/HBoxContainer/LogoContainer.hide()
	hideRight()
	$MarginContainer/HBoxContainer/ToolsContainer.show()


func _on_ToolsItemTag_pressed():
	return get_tree().change_scene("res://scenes/tools/itemTag/itemTag.tscn")

func _ready():
	#$MarginContainer/HBoxContainer/ToolsContainer.hide()
	
	var modFolder = GameManager.folderMod
	var directory = Directory.new();
	var modFolderExists = directory.dir_exists(modFolder)
	
	if modFolderExists:
		$MarginContainer/HBoxContainer/MenuVBoxContainer/MenuButtons/ModsButton.show()
	else:
		$MarginContainer/HBoxContainer/MenuVBoxContainer/MenuButtons/ModsButton.hide()

func _on_ModsButton_pressed():
	hideRight()
	$MarginContainer/HBoxContainer/ModOverview.show()
	
func hideRight():
	$MarginContainer/HBoxContainer/LogoContainer.hide()
	$MarginContainer/HBoxContainer/ToolsContainer.hide()
	$MarginContainer/HBoxContainer/ModOverview.hide()


func _on_LoadGameButton_pressed():
	$LoadGameDialog.popup_centered()


func _on_LoadGameDialog_file_selected(path):
	GameManager.loadGame(path)
