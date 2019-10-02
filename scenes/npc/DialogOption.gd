extends Button

var id

func _pressed():
	get_tree().call_group("gameCommand","npcDialogOption",id)

func setContent(option):
	text = option.text
	id = option.ID
