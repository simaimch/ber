extends VBoxContainer

var plLogEntry = preload("res://scenes/main/LogContainer/LogEntry.tscn")

const maxEntries = 100

func logOut(msg,type):
	var time = str(OS.get_ticks_msec())+"("+Util.formtTime(OS.get_unix_time(),"{hour}:{minute}:{second}")+")"
	
	var leInstance = plLogEntry.instance()
	leInstance.text = time+" : "+msg
	
	if type == "ERROR": leInstance.font_color = Color(1,0,0)
	
	add_child(leInstance)
	move_child(leInstance,0)
	
	if get_child_count() > maxEntries:
		 get_child(maxEntries).queue_free()