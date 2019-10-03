extends CheckButton


func _on_ShowOwnedCheck_toggled(button_pressed):
	GameManager.CurrentUi.ShopShowOwned = pressed
	GameManager.shopUpdateItems()

func updateUI(CurrentUi):
	pressed = CurrentUi.ShopShowOwned
