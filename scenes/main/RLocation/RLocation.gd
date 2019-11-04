extends Button

var duration = 0
var transferInfo

func _pressed():
	get_tree().call_group("tooltip","hideTooltip",{})
	get_tree().call_group("gameCommand","gotoLocation",transferInfo)#.locationId,transferInfo.time,"walk")

func setLocation(l):
	transferInfo = l
	var t = ""
	var targetLocation = GameManager.getLocation(transferInfo.locationId)
	if "label" in transferInfo:
		t = transferInfo.label
	elif "label" in targetLocation:
		t = targetLocation.label
	elif targetLocation.has("text"):
		t = targetLocation.text
	setText(t)
	
	$VBoxContainer/TimeLabel.text = "("+Util.formatDuration(transferInfo.time)+")"
	
	if GameManager.hasValue(targetLocation,"rlTexture"):
		setTexture(GameManager.getValue(targetLocation,"rlTexture"))
	elif GameManager.hasValue(targetLocation,"bg"):
		setTexture(GameManager.getValue(targetLocation,"bg"))

func setText(text):
	$VBoxContainer/Label.text = text
	
func setTexture(path):
	var texture = Util.texture(path)#load(path)
	$VBoxContainer/TextureRect.set_texture(texture)

func _on_RLocation_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":$VBoxContainer/Label.text+"\n"+str(transferInfo.time)+" seconds","followMouse":true})


func _on_RLocation_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
