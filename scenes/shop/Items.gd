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
		itemInstance.setTexture(load(item.texture))
		add_child(itemInstance)
	yield(get_tree(), "idle_frame")
	repositionItems()
	
func _ready():
	
	#var textures = Util.getFilesInFolder("res://media/texture/items/dress")
	#for texture in textures:
	#	if texture.split(".").size() == 2:
	#		var item = itemPL.instance()
	#		var path = "res://media/texture/items/dress/"+texture
			
	#		item.setTexture(load(path))
	#		add_child(item)
			
	
	repositionItems()

	
func repositionItems():
	#var screenWidth = get_parent().get_parent().rect_size.x
	var x = 0
	var y = 0
	for child in get_children():
		#var textureSize = child.texture.get_size()
		#child.rect_size.x = size*textureSize.x/textureSize.y
		#child.rect_size.y = size
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
	
	#get_parent().get_parent().get_v_scrollbar().max_value = y + size
	rect_min_size.y = y + size
	#get_parent().rect_min_size.y = y + size
	#get_parent().rect_min_size.y  = 2000
	#get_parent().rect_size.y = 2000
	
	#get_parent().rect_size.x = 2000
	#print(get_parent().rect_size.y)

func _on_Control_resized():
	screenWidth = rect_size.x
	repositionItems()
