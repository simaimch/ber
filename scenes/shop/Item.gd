extends Button

var item

func setHeight(h):
	var textureSize = $Texture.texture.get_size()
	var w = h * textureSize.x / textureSize.y
	
	rect_size.x = w
	rect_size.y = h
	
	$Texture.rect_size.x = w
	$Texture.rect_size.y = h

func setItem(i):
	item = i
	setTexture(load(item.texture))

func setTexture(t):
	$Texture.texture = t
	setHeight(rect_size.y)

func _on_Item_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":item.ID,"followMouse":true})


func _on_Item_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})

func _on_Item_pressed():
	get_tree().call_group("uiShopDialogue","showBuyDialogue",item)

