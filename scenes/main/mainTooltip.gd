extends Control

var followMouse = false

func _ready():
	set_process(false)

func _process(delta):
	rect_position = get_viewport().get_mouse_position() - rect_size
	rect_position.x = max(rect_position.x,0)
	rect_position.y = max(rect_position.y,0)

func hideTooltip(args):
	followMouse = false
	set_process(followMouse)
	hide()

func showTooltip(args):
	show()
	if args.has("text"):
		$CenterContainer/Label.text = args.text
		$CenterContainer/Label.show()
	else:
		$CenterContainer/Label.hide()
		
	if args.has("pos"):
		rect_position = args.pos - rect_size
	else:
		rect_position = Vector2(0,0)
		
	if args.has("followMouse"):
		followMouse = args.followMouse
		set_process(followMouse)
		
		
	