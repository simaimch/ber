extends TextureRect


func updateUI(CurrentUi):
	#var item = GameManager.itemWornAtSlot("clothes")
	#texture = Util.texture(item.texture)
	pass


func _on_HairTexture_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":"Current Hair Length: "+str(int(GameManager.getValueFromPath("PlayerData.body.hair.length")/10000))+" cm","followMouse":true})


func _on_HairTexture_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
	