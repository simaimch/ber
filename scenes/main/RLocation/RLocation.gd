extends Button

var duration = 0
var transferInfo

func _pressed():
	get_tree().call_group("gameCommand","gotoLocation",transferInfo.locationId,transferInfo.time)

func setLocation(l):
	transferInfo = l
	var t = ""
	var targetLocation = GameManager.getLocation(transferInfo.locationId)
	if "label" in transferInfo:
		t = transferInfo.label
	else:
		t = targetLocation.text
	setText(t)
	setTexture(GameManager.getValue(targetLocation,"bg"))

func setText(text):
	$Label.text = text
	
func setTexture(path):
	var texture = load(path)
	$TextureRect.set_texture(texture)