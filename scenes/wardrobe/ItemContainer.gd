extends VBoxContainer

var itemPL = preload("res://scenes/wardrobe/Item.tscn")
	

func clearChildren():
	for i in get_children():
		i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for item in CurrentUi.Wardrobe.selitems:
		var itemInstance = itemPL.instance()
		itemInstance.setItem(item)
		add_child(itemInstance)
