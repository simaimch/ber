extends HBoxContainer

var modId

func setMod(id):
	modId = id
	
	
	var modInfo = GameManager.loadModInfo(id)
	
	if GameManager.Preferences.mods.has(modId):
		modInfo.active = GameManager.Preferences.mods[modId]
	else:
		modInfo.active = GameManager.Preferences.modsAutoactivate
		GameManager.Preferences.mods[modId] = modInfo.active
	
	$VBoxContainer/HBoxContainer/Title.text = modInfo.name
	
	if modInfo.description.empty():
		$VBoxContainer/Description.hide()
	else:
		$VBoxContainer/Description.show()
		$VBoxContainer/Description.text = modInfo.description
		
	if modInfo.version == 0:
		$VBoxContainer/HBoxContainer/Version.hide()
	else:
		$VBoxContainer/HBoxContainer/Version.show()
		$VBoxContainer/HBoxContainer/Version.text= Util.formatVersion(modInfo.version)
		
	$CheckButton.pressed = modInfo.active

func _on_CheckButton_pressed():
	GameManager.Preferences.mods[modId] = $CheckButton.pressed
