extends Control

func executeAction(action):
	GameManager.execute(action)

func gotoLocation(targetLocation,time):
	GameManager.gotoLocation(targetLocation,time)
	#updateUI()

func _process(delta):
	if Input.is_action_pressed("ui_quickload"):
		GameManager.SaveGameLoad()
		#updateUI()
	elif Input.is_action_pressed("ui_quicksave"):
		GameManager.SaveGameSave()

func _ready():
	GameManager.updateUI()
	

