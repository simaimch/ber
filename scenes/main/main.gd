extends Control

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

func _process(delta):
	if Input.is_action_pressed("ui_quickload"):
		GameManager.SaveGameLoad()
		#updateUI()
	elif Input.is_action_pressed("ui_quicksave"):
		GameManager.SaveGameSave()
	elif Input.is_action_pressed("ui_details"):
		GameManager.detailsShow()

func _ready():
	GameManager.updateUI()
	

