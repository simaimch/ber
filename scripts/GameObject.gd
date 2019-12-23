extends Reference

class_name GameObject

var objectData:Dictionary

func _init(param):
	match typeof(param):
		TYPE_STRING:
			objectData = getDataById(param)
		TYPE_DICTIONARY:
			objectData = param
		var paramType:
			LOG.out(["Param of type ",paramType," not supported in GameObject._init()"],LOG.ERROR)
	
	var object2inherit = get("inherit")
	
	match typeof(object2inherit):
		TYPE_STRING:
			var objectId =  object2inherit
			var object = newObject(objectId)
			inherit(object.data())
		TYPE_ARRAY:
			for objectId in object2inherit:
				var object = newObject(objectId)
				inherit(object.data())
				
	inherit(getPersistentData(),"parent")

func data()->Dictionary:
	return objectData

func get(property:String,default=null):
	return GameManager.getValue(data(),property,default)

static func getDataById(id:String)->Dictionary:
	return {}

func getPersistentData()->Dictionary:
	return getPersistentDataById(id())

static func getPersistentDataById(id:String)->Dictionary:
	return {}
	
func id()->String:
	return get("ID","0")

func inherit(inheritanceData:Dictionary,mode="child"):

	var removeTemplateTag = false
	
	if inheritanceData.get("isTemplate",false) == true and objectData.get("isTemplate",false) == false:
		removeTemplateTag = true
	
	objectData = Util.mergeInto(objectData, inheritanceData, false)
	
	if removeTemplateTag:
		objectData.erase("isTemplate")
		
	
static func newObject(id:String)->GameObject:
	return null
	
func texture()->Texture:
	return Util.texture(get("texture"))
