extends Control

var npc:NPC

func _on_TalkButton_pressed():
	close()
	GameManager.npcDialogShow(npc)


func _on_LeaveButton_pressed():
	GameManager.npcDetailsHide()

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and GameManager.CurrentUi.get("ShowDetailsNPC",false):
		close()
		
func close():
	GameManager.npcDetailsHide()

func setNPC(n:NPC):
	npc = n
	#var texturePath:String = GameManager.getValue(npc,"texture","")
	#$HBoxContainer/PortraitTexture.texture = Util.texture(texturePath)
	$HBoxContainer/PortraitTexture.texture = npc.texture()
	
	#var name:String = GameManager.getNPCDescription(npc)
	#var name:String = GameManager.getValueFromFunction("npcKnownName",npc)
	#$HBoxContainer/VBoxContainer/NameLabel.text = name
	$HBoxContainer/VBoxContainer/NameLabel.text = npc.knownName()
	
	$HBoxContainer/VBoxContainer/Description.bbcode_text = npc.description()
	
func updateUI(CurrentUi):
	if CurrentUi.get("ShowDetailsNPC",false) == true:
		show()
	else:
		hide()


