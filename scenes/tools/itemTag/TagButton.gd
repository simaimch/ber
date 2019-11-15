extends TextureButton

export var Number:String

var textureRect
var textlabel

func _ready():
	textureRect = $VBoxContainer/TextureRect
	textlabel = $VBoxContainer/Label

func setColor(c):
	if c == null:
		#$ColorRect.color = Color(0,0,0,0)
		$ColorRect.hide()
	else:
		$ColorRect.color = Color(c)
		
		$ColorRect.show()
	textureRect.hide()

func setGradient(colors):
	if colors.empty(): return setColor(null)
	if colors.size() == 1: return setColor(colors[0])
	
	var gradient = Gradient.new()
	gradient.colors = PoolColorArray(colors)
	var texture = GradientTexture.new()
	texture.gradient = gradient
	
	textureRect.texture = texture
	textureRect.show()
	$ColorRect.hide()
	
func setTexture(t):
	texture_normal = t
	
func setLabel(s:String):
	if s.empty():
		textlabel.hide()
	else:
		textlabel.show()
		textlabel.text = s