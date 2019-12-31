extends GameObject

class_name Shop

# Override Start

func _init(p).(p):
   pass

static func getDataById(id:String)->Dictionary: 
	return GameManager.misc.shops.get(id,{})
	
static func getPersistentDataById(id:String)->Dictionary:
	return {}


static func newObject(id:String)->GameObject: 
	return (load("res://scripts/Shop.gd") as Script).new(id)


# Override End
