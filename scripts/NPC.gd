extends GameObject

class_name NPC

func _init(p).(p):
   pass

static func getDataById(id:String)->Dictionary: 
	#return GameManager.getNPC(id)
	return GameManager.npcs.get(id,{})
	
static func getPersistentDataById(id:String)->Dictionary:
	return GameManager.NPCData.get(id,{})

func knownName()->String:
	return GameManager.getValueFromFunction("npcKnownName",data())

static func newObject(id:String)->GameObject: 
	#return NPC.new(id)
	return (load("res://scripts/NPC.gd") as Script).new(id)
