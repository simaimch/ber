extends TextureRect

var tooltip = null

func setMod(statusMod):
	var texturePath = GameManager.getValue(statusMod,"statBarTexture","")
	texture = Util.texture(texturePath)
	tooltip = GameManager.getValue(statusMod,"label")

func _on_StatusMod_mouse_entered():
	if tooltip: get_tree().call_group("tooltip","showTooltip",{"text":tooltip,"followMouse":true})


func _on_StatusMod_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
