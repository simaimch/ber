extends VBoxContainer

export var label:String
export var type:String

func _ready():
	$Label.text = label 

func updateUI(CurrentUi):
	var itemId = CurrentUi.Wardrobe.coutfit[type]
	var item = GameManager.getItem(itemId)
	$TextureButton.texture_normal = load(item.texture)
	

func _on_TextureButton_pressed():
	GameManager.CurrentUi.Wardrobe.seltype = type
	GameManager.wardrobeUpdateItems()
