extends PopupPanel

var fname = ""
var lname = ""

var fname_list = "names_first_female_90s"
var lname_list = "names_last"

func _on_Confirm_pressed():
	if fname.empty():
		setFnameRandom()
	if lname.empty():
		setLnameRandom()
	
	GameManager.PlayerData.name.first = fname
	GameManager.PlayerData.name.last = lname
	GameManager.UIGroupStackPop()
	GameManager.recalcUI()
	queue_free()
	



func _on_FirstName_text_changed(new_text):
	fname = new_text


func _on_LastName_text_changed(new_text):
	lname = new_text


func _on_pcName_about_to_show():
	pass

func setFname(s):
	fname = s
	$CenterContainer/VBoxContainer/FirstNameContainer/FirstName.text = fname

func setLname(s):
	lname = s
	$CenterContainer/VBoxContainer/LastNameContainer/LastName.text = lname

func setFnameRandom():
	setFname(GameManager.getValueFromList(fname_list))
	
func setLnameRandom():
	setLname(GameManager.getValueFromList(lname_list))

func setParam(dialogParam):
	if typeof(dialogParam) != TYPE_DICTIONARY:
		LOG.error("Unsupported type of dialogParam in pcName")
		return
	if dialogParam.has("listNameFirst"): fname_list = dialogParam.get("listNameFirst")
	if dialogParam.has("listNameLast"): lname_list = dialogParam.get("listNameLast")


func _on_FirstNameRandomButton_pressed():
	setFnameRandom()


func _on_LastNameRandomButton_pressed():
	setLnameRandom()
