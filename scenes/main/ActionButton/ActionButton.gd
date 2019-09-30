extends Button

var action

func _pressed():
	get_tree().call_group("gameCommand","executeAction",action)
	
func setAction(a):
	action = a
	text = action.Label