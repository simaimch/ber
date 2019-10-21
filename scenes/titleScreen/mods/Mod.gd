extends HBoxContainer

var modId

func setMod(id):
	modId = id
	
	
	var modInfo = GameManager.loadModInfo(id)
	
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