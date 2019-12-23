extends VBoxContainer

var optionPL = preload("res://scenes/npc/DialogOption.tscn")

func clearChildren():
	for i in get_children():
		i.queue_free()
		

func updateUI(CurrentUi):
	clearChildren()
	
	for option in CurrentUi.NPCDialogOption:
		var optionInstance = optionPL.instance()
		optionInstance.setContent(option)
		add_child(optionInstance)
