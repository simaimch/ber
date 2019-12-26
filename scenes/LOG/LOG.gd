extends Control

var ERROR:int = 1
var NOTICE:int = 2
var DEBUG:int = 3

func error(msg):
	out(msg,ERROR)

func out(msg,type:int=0):
	
	if typeof(msg) == TYPE_ARRAY:
		var text = ""
		for t in msg:
			text += str(t)
		msg = text
	else:
		msg = str(msg)
	
	get_tree().call_group("logger","logOut",msg,type)
