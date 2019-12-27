extends Label

var modifier

func setModifer(m):
	modifier = m
	text = GameManager.getValue(modifier,"label","Label Missing")

func _on_Modifier_mouse_entered():
	var t = GameManager.getValue(modifier,"description",null)
	if t:
		get_tree().call_group("tooltip","showTooltip",{"text":t,"followMouse":true})


func _on_Modifier_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
