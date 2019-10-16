extends Button

var categoryID = ""

func setCategory(category):
	categoryID = category.ID
	$VBoxContainer/Label.text = category.label
	$VBoxContainer/TextureRect.texture = Util.texture(category.texture)

func _on_ServiceCategory_pressed():
	GameManager.CurrentUi.Services.category = categoryID
	GameManager.updateUI()
