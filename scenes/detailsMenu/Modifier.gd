extends Label

var modifier

func setModifer(m):
	modifier = m
	text = modifier.label

func _on_Modifier_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":modifier.description,"followMouse":true})


func _on_Modifier_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
