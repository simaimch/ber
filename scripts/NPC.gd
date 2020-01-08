extends GameObject

class_name NPC

# Override Start

func _init(p).(p):
   pass

static func getDataById(id:String)->Dictionary: 
	return GameManager.npcs.get(id,{})
	
static func getPersistentDataById(id:String)->Dictionary:
	return GameManager.NPCData.get(id,{})


static func newObject(id:String)->GameObject: 
	return (load("res://scripts/NPC.gd") as Script).new(id)


# Override End

func activity(time = -1)->Dictionary:
	if get("isTemplate",false) == true: return {"locationId":"none","acticity":"none"}
	
	var schedule = get("schedule",{})
	
	for scheduleLocationId in schedule:
		var activity = activityAtLocation(scheduleLocationId,time)
		if activity != "none":
			return {"locationId":scheduleLocationId,"activity":activity}
		
	return {"locationId":"none","acticity":"none"}
	
func activityAtLocation(locationId:String,time = -1)->String:
	#var value = GameManager.value(self)
	
	if time == -1: time =  GameManager.now()
	
	var timeDict = Util.getDateTime(time)
	
	if get("isTemplate",false) == true: return "none"
	
	var schedule = get("schedule")
	if !schedule: return "none"
	var scheduleAtLocation = schedule.get(locationId,null)
	if !scheduleAtLocation: return "none"
	
	for presence in scheduleAtLocation:
		if timeDict.weekday in presence.days:
			var timeBase100 = timeDict.hour * 100 + timeDict.minute
			if timeBase100 >= presence.timeStart and timeBase100 <= presence.timeEnd:
				return GameManager.getValue(presence,"activity","idle")
	return "none"

func description()->String:

	var lines = []

	var descriptions = get("description",{})

	for descriptionId in descriptions:
		var description = descriptions[descriptionId]
		if !description.has('condition') or GameManager.checkConditionParameter(description.condition,self):
			lines.append(stringFormat(description.get("text","No text")))
	lines.sort_custom(Sorter,"sortByPriority")
	return PoolStringArray(lines).join("\n")

func knownName()->String:
	return GameManager.getValueFromFunction("npcKnownName",data())
	
func stringFormat(s):
	var dict = {}
	if get("gender","f") == "f":
		dict["she"] = "she"
		dict["her"] = "her"
	else:
		dict["she"] = "he"
		dict["her"] = "his"
	
	var keys = dict.keys()
	
	for key in keys:
		var newKey = key.capitalize()
		var newValue=dict[key].capitalize()
		dict[newKey]=newValue
		
	return s.format(dict)
	
