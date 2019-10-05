extends PopupDialog

var fname = ""
var lname = ""

func _on_Confirm_pressed():
	if fname.empty():
		setFnameRandom()
	if lname.empty():
		setLnameRandom()
	
	GameManager.PlayerData.name.first = fname
	GameManager.PlayerData.name.last = lname
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
	setFname(GameManager.getValueFromList("names_first_female_90s"))
	
func setLnameRandom():
	setLname(GameManager.getValueFromList("names_last"))

func _on_FirstNameRandomButton_pressed():
	setFnameRandom()


func _on_LastNameRandomButton_pressed():
	setLnameRandom()
