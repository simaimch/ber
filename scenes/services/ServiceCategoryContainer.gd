extends HBoxContainer


var catPL = preload("res://scenes/services/ServiceCategory.tscn")
	

func clearChildren():
	for i in get_children():
		i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for categoryId in CurrentUi.Services.availableCategories:
		var category = CurrentUi.Services.availableCategories[categoryId]
		var catInstance = catPL.instance()
		catInstance.setCategory(category)
		add_child(catInstance)
