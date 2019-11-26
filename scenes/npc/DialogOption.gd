extends Button

#var message:String=""
#var topic:String=""
var reply:Dictionary

func _pressed():
	GameManager.npcDialogReply(reply)

func setContent(r):
	reply = r
	text = GameManager.getValue(reply,"label","No Label")