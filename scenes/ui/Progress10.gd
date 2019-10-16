extends HBoxContainer

func setValue(value):
	for i in range(0,9):
		if value > i:
			get_child(i).color = Color(1,0,0,1) 
		else:
			get_child(i).color = Color(0,0,0,1) 