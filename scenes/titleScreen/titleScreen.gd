extends Control

func _on_ContinueButton_pressed():
	return get_tree().change_scene("res://scenes/continueGameScreen/continueGameScreen.tscn")


func _on_NewGameButton_pressed():
	return get_tree().change_scene("res://scenes/newGameScreen/newGameScene.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()



func _on_Tools_pressed():
	$MarginContainer/HBoxContainer/LogoContainer.hide()
	$MarginContainer/HBoxContainer/ToolsContainer.show()


func _on_ToolsItemTag_pressed():
	return get_tree().change_scene("res://scenes/tools/itemTag/itemTag.tscn")

func _ready():
	$MarginContainer/HBoxContainer/ToolsContainer.hide()