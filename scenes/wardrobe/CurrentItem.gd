extends VBoxContainer

export var label:String
export var type:String

func _ready():
	$Label.text = label 

func updateUI(CurrentUi):
	#var itemId = GameManager.getValue(CurrentUi.Wardrobe.coutfit,type)
	#if itemId == "" or itemId == null or itemId == "naked":
	#	$TextureButton.texture_normal = Util.texture(GameManager.getValueFromPath("PlayerData.body."+type+".texture"))
	#else:
	#	var item = GameManager.getItem(itemId)
	#	$TextureButton.texture_normal = load(item.texture)
	var item = GameManager.itemWornAtSlot(type)
	$TextureButton.texture_normal = Util.texture(item.texture)

func _on_TextureButton_pressed():
	GameManager.CurrentUi.Wardrobe.seltype = type
	GameManager.wardrobeUpdateItems()


func _on_UndressButton_pressed():
	GameManager.undress(type)
