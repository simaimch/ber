extends VBoxContainer

var MessagePL = preload("res://scenes/main/Message/Message.tscn")

func messageShow(message:Dictionary):
	var MessageInstance = MessagePL.instance()
	MessageInstance.setMessage(message)
	add_child(MessageInstance)