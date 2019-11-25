extends Button

var duration = 0
var transferInfo
var disable = false
var tooltip = ""

func _pressed():
	if !disable:
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
	
	if GameManager.getValue(transferInfo,"disabled",false) == true:
		disable = true
		$VBoxContainer/Label.set("custom_colors/font_color",Color(1,0,0))
	else:
		disable = false
		
	tooltip = GameManager.getValue(transferInfo,"tooltip","")
	if tooltip == "":
		tooltip = t+"\n"+str(transferInfo.time)+" seconds"
	
	$VBoxContainer/TimeLabel.text = "("+Util.formatDuration(transferInfo.time)+")"
	
	if GameManager.getValue(transferInfo,"textureDisabled",false) == true:
		$VBoxContainer/TextureRect.hide()
		$VBoxContainer/TimeLabel.hide()
		rect_min_size.y = 0
	else:
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
	get_tree().call_group("tooltip","showTooltip",{"text":tooltip,"followMouse":true})


func _on_RLocation_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
