extends VBoxContainer

var modifierPL = preload("res://scenes/detailsMenu/Modifier.tscn")

func clearChildren():
	for i in get_children():
    	i.queue_free()

func updateUI(CurrentUi):
	clearChildren()
	for modifier in CurrentUi.ActiveModfiers["appearance"]:
		var modifierInstance = modifierPL.instance()
		modifierInstance.setModifer(modifier)
		add_child(modifierInstance)
