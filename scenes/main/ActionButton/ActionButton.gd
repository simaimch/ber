extends Button

var action

func _pressed():
	get_tree().call_group("gameCommand","executeAction",action)
	
func setAction(a):
	action = a
	text = action.get("Label","ERROR: Label missing")
	if action.has("Disabled") and action.Disabled == true:
		disabled = true
	

func _on_Button_mouse_entered():
	if action.has("Tooltip"):
		get_tree().call_group("tooltip","showTooltip",{"text":action.Tooltip,"followMouse":true})


func _on_Button_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
