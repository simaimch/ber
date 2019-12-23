extends Control
var size = 400
var screenWidth = rect_size.x

var itemPL = preload("res://scenes/shop/Item.tscn")

func clearChildren():
	for i in get_children():
		i.queue_free()

func updateUI(CurrentUi):
	createItems(CurrentUi.ShopItems)

func createItems(items):
	clearChildren()
	for item in items:
		var itemInstance = itemPL.instance()
		#itemInstance.setTexture(load(item.texture))
		itemInstance.setItem(item)
		add_child(itemInstance)
	yield(get_tree(), "idle_frame")
	repositionItems()
	
func repositionItems():
	var x = 0
	var y = 0
	for child in get_children():
		child.setHeight(size)
		
		if x + child.rect_size.x > screenWidth:
			y += size
			x = 0
		
		child.rect_position.x = x
		child.rect_position.y = y
		x += child.rect_size.x
	
	var tree = get_tree()
	if tree == null: return
	yield(tree, "idle_frame")

	rect_min_size.y = y + size


func _on_Control_resized():
	screenWidth = rect_size.x
	repositionItems()
