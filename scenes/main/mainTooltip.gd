extends Control

var followMouse = false
var sizeUpdated = false

func _ready():
	hide()
	set_process(false)

func _process(delta):
	if !sizeUpdated:
		rect_size = rect_min_size
		sizeUpdated = true
		set_process(followMouse)
	
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
		$CenterContainer/TooltipLabel.text = args.text
		$CenterContainer/TooltipLabel.show()
	else:
		$CenterContainer/TooltipLabel.hide()
		
	if args.has("pos"):
		rect_position = args.pos - rect_size
	else:
		rect_position = Vector2(0,0)
		
	if args.has("followMouse"):
		followMouse = args.followMouse
		set_process(true)
	
	sizeUpdated = false
	
		
	