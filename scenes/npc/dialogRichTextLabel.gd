extends RichTextLabel

func _ready():
	updateSize()
	
func setText(t):
	text = t
	updateSize()
	
func updateSize():
	var tree = get_tree()
	if tree == null: return
	yield(tree, "idle_frame")
	
	rect_size.y = get_v_scroll().get_max()
	get_parent().rect_min_size.y = get_v_scroll().get_max()