extends PanelContainer

var age:float

func _process(delta):
	age += delta
	if age >= 4:
		queue_free()
	elif age >= 2:
		modulate = Color(1,1,1,1-(age-2.0)/2.0)

func setMessage(message:Dictionary):
	age = 0
	if message.has("text"): $Label.text = message.text