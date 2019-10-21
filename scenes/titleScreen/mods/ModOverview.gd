extends VBoxContainer

var modsContainer

func _ready():
	modsContainer = $ScrollContainer/ModsContainer
	updateModList()
	$HBoxContainer/AutoactivateMods.pressed = GameManager.Preferences.modsAutoactivate

func updateModList():
	Util.clearChildren(modsContainer)
	var modPL = preload("res://scenes/titleScreen/mods/Mod.tscn")
	
	var modFolders = Util.getFoldersInFolder(GameManager.folderMod)
	
	if modFolders.size() == 0:
		$NoModsFoundLabel.show()
		$ScrollContainer.hide()
	else:
		$NoModsFoundLabel.hide()
		$ScrollContainer.show()
		for modFolder in modFolders:
			var modInstance = modPL.instance()
			modInstance.setMod(modFolder)
			modsContainer.add_child(modInstance)

func _on_Refresh_pressed():
	updateModList()

func updatePreferences():
	GameManager.savePreferences()
	
func _on_ModOverview_tree_exited():
	updatePreferences()


func _on_ModOverview_hide():
	updatePreferences()



func _on_AutoactivateMods_pressed():
	GameManager.Preferences.modsAutoactivate = $HBoxContainer/AutoactivateMods.pressed
