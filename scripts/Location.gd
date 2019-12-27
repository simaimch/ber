extends GameObject

class_name Location

# Override Start

func _init(p).(p):
   pass

static func getDataById(id:String)->Dictionary: 
	return GameManager.locationData(id)
	
static func getPersistentDataById(id:String)->Dictionary:
	return {}


static func newObject(id:String)->GameObject: 
	return (load("res://scripts/Location.gd") as Script).new(id)


# Override End


