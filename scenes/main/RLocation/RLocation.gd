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
	elif "label" in targetLocation:
		t = targetLocation.label
	else:
		t = targetLocation.text
	setText(t)
	
	if GameManager.hasValue(targetLocation,"rlTexture"):
		setTexture(GameManager.getValue(targetLocation,"rlTexture"))
	elif GameManager.hasValue(targetLocation,"bg"):
		setTexture(GameManager.getValue(targetLocation,"bg"))

func setText(text):
	$Label.text = text
	
func setTexture(path):
	var texture = Util.texture(path)#load(path)
	$TextureRect.set_texture(texture)