extends GridContainer

func updateUI(CurrentUi):
	$FirstNameDisplay.text = GameManager.PlayerData.name.first
	$LastNameDisplay.text = GameManager.PlayerData.name.last