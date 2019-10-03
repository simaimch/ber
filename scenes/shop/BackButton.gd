extends Button


func _on_BackButton_pressed():
	get_tree().call_group("gameCommand","shopClose")
	
