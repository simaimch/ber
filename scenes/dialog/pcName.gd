extends PopupDialog

var fname = ""
var lname = ""

func _on_Confirm_pressed():
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
