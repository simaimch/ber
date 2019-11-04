extends PopupPanel

var param = {}

func _on_ConfirmButton_pressed():
	var value = $CenterContainer/VBoxContainer/LineEdit.text
	if param.has("validateRegex"):
		var regex = RegEx.new()
		regex.compile(param.validateRegex)
		var result = regex.search(value)
		if !result:
			if param.has("validateHint"): error(param.validateHint)
			else: error("Input needs to match regex: "+param.validateRegex)
			return
	GameManager.setValueAtPath(param.target,value)
	if GameManager.getValue(param,"updateLocation",false) == true: GameManager.updateLocation()
	queue_free()

func error(msg):
	$CenterContainer/VBoxContainer/ErrorLabel.text = msg
	$CenterContainer/VBoxContainer/ErrorLabel.show()

func label(msg):
	$CenterContainer/VBoxContainer/Label.text = msg
	$CenterContainer/VBoxContainer/Label.show()

func setValue(v):
	$CenterContainer/VBoxContainer/LineEdit.text = v

func setParam(p):
	param = p
	if param.has("label"): label(param.label)
	if param.has("value"): setValue(str(param.value))