extends Button

var action
var button = -1

func activate():
	get_tree().call_group("gameCommand","executeAction",action)
	
func _pressed():
	activate()

func buttonPressed(buttonIndex):
	if buttonIndex == button: activate()

func setAction(a,b = -1):
	action = a
	button = b
	#text = action.get("Label","ERROR: Label missing")
	text = GameManager.getValue(action,"Label","ERROR: Label missing")
	
	if(button >= 0 and button <= 9):
		text = ""+str(button)+" "+text
	
	if action.has("Disabled") and action.Disabled == true:
		disabled = true
	

func _on_Button_mouse_entered():
	if action.has("Tooltip"):
		get_tree().call_group("tooltip","showTooltip",{"text":action.Tooltip,"followMouse":true})


func _on_Button_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
