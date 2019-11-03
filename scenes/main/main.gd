extends Control

var action = ""

func executeAction(action):
	GameManager.execute(action)

func gotoLocation(transferInfo):#targetLocation,time,mode):
	GameManager.gotoLocation(transferInfo)#targetLocation,time,mode)
	#updateUI()

func npcDialog(npc):
	GameManager.npcDialog(npc)
	
func npcDialogOption(id):
	GameManager.npcDialogOption(id)

func shopClose():
	GameManager.shopClose()

# warning-ignore:unused_argument
func _process(delta):
	
	if Input.is_action_pressed("ui_quickload"):
		#GameManager.SaveGameLoad()
		#updateUI()
		action = "quickload"
	elif Input.is_action_pressed("ui_quicksave"):
		#GameManager.SaveGameSave()
		action = "quicksave"
	elif Input.is_action_pressed("ui_details"):
		#GameManager.detailsShow()
		action = "details"
	elif Input.is_action_pressed("ui_menu"):
		#GameManager.gameMenuShow()
		action = "menu"
	elif Input.is_action_pressed("ui_gamestatus"):
		action = "gamestatus"
	elif action == "quickload":
		GameManager.SaveGameLoad()
		action = ""
	elif action == "quicksave":
		GameManager.SaveGameSave()
		action = ""
	elif action == "details":
		GameManager.detailsShow()
		action = ""
	elif action == "menu":
		GameManager.gameMenuShow()
		action = ""
	elif action == "gamestatus":
		GameManager.gameStatusToggle()
		action = ""

func _ready():
	GameManager.updateUI()
	

