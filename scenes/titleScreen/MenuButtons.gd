extends VBoxContainer

func _ready():
	for button in self.get_children():
		button.connect("pressed",self,"_on_Button_pressed",[button.Target_Szene])

func _on_Button_pressed(Target_Szene):
	if Target_Szene == "quit":
		get_tree().quit()
	else:
		return get_tree().change_scene(Target_Szene)
