extends Control

class SorterByIndexInt:
	static func sort(a, b):
		if int(a) < int(b):
			return true
		return false
		
	static func sortInv(a ,b):
		return sort(b,a)

const mainScene = "res://scenes/main/main.tscn"
var rng = RandomNumberGenerator.new()

var CurrentUi={
	"Actions":[],
	"LocationId":"",
	"NPCs":[],
	"NPCDialog":[],
	"NPCDialogOption":[],
	"ShowNPCDialog":false,
	"ShowNPCs":false,
	"ShowPlayerStat":true,
	"ShowRL": true,
	"ShowTime": true,
	"RL":[],
	"Time":0
}

var MetaData = {}

var PlayerData = {
	"stat":{
		"hunger":{
			"current":10000,
			"decay":0.2
		},
		"thirst":{
			"current":10000,
			"decay":0.3
		},
		"sleep":{
			"current":10000,
			"decay":0.15
		}
	}
}

var WorldData = {
	"Time": 0,
	"TimeOffset":1537430400,
	"Weather":"clear",
	"SunPosition":"dawn"
}

var MiscData = {
	currentNpcId = [""],
	currentDialogueID = ""
}

var dialogues = {}
var locations = {}
var npcs = {}

func _ready():
	playerData2UI()
	CurrentUi.Time = WorldData.Time + WorldData.TimeOffset
	rng.randomize()
	
func now():
	var now = WorldData.Time + WorldData.TimeOffset
	return now

func getDialogue(dialogueId):
	var dialogueArr = dialogueId.split(".")
	
	if !dialogues.has(dialogueArr[0]):
		loadDialogue(dialogueArr[0])
	var d = dialogues[dialogueArr[0]] 
		
	var i = 1
	while i < dialogueArr.size():
		if !d.has(dialogueArr[i]): return d
		d = d[dialogueArr[i]]
		i += 1
	
	d["SELF"] = dialogueArr[0]
	d["ID"] = dialogueId
	return d

func getLocation(locationId):
	
	var locationArr = locationId.split(".")
	
	
	if !locations.has(locationArr[0]):
		loadLocation(locationArr[0])
	var l = locations[locationArr[0]] 
		
	var i = 1
	while i < locationArr.size():
		if !l.has(locationArr[i]): return l
		l = l[locationArr[i]]
		i += 1
	
	l["SELF"] = locationArr[0]
	l["ID"] = locationId
	return l
	
func getNPC(npcId):
	#all NPCs get loaded at the beginning of the game, no need to load them here
	var npc = npcs[npcId]
	npc["ID"] = npcId
	if !hasValue(npc,"initialized") or getValue(npc,"initialized") == false:
		initNpc(npc)
	return npc

func getNPCDescription(npc):
	var result = ""
	var gender = getValue(npc,"gender")
	var bday = getValue(npc,"bday")
	var age = Util.getAge(now(),bday)
	
	if(age < 2):
		result = "An infant"
	elif(age < 5):
		result = "A toddler"
		if gender == "f": result += " girl"
		elif gender == "m": result += " boy"
	elif(age < 10):
		result = "A little"
		if gender == "f": result += " girl"
		elif gender == "m": result += " boy"
		else: result += " child"
	elif(age < 13):
		result = "A preadolescent "
		if gender == "f": result += " girl"
		elif gender == "m": result += " boy"
		else: result += " tween"
	elif(age < 18):
		result = "A teenage"
		if gender == "f": result += " girl"
		elif gender == "m": result += " boy"
		else: result += "r"
	elif(age < 40):
		result = "A young adult"
		if gender == "f": result += " woman"
		elif gender == "m": result += " man"
	elif(age < 65):
		result = "A middle-aged"
		if gender == "f": result += " woman"
		elif gender == "m": result += " man"
		else: result += " person"
	else:
		result = "An old"
		if gender == "f": result += " woman"
		elif gender == "m": result += " man"
		else: result += " person"
	return result

func initNpc(npc):
	if npc.has("persist"):
		npc.persist = initEntry(npc.persist)
	else:
		npc.persist = {}
	print("NPC "+npc.ID+" initialized")
	npc.persist.initialized = true
	
func initEntry(entry):
	if typeof(entry) == TYPE_STRING and entry[0] == "*":
		entry.erase(0,1)
		return getValueFromList(entry)
	if typeof(entry) in [TYPE_STRING, TYPE_BOOL, TYPE_INT, TYPE_REAL]:
		return entry
	if typeof(entry) == TYPE_DICTIONARY:
		var newDict = {}
		for key in entry:
			newDict[key] = initEntry(entry[key])
		return newDict
	
func hasValue(obj, index):
	if obj.has(index): return true
	if obj.has("persist"): return hasValue(obj.persist, index)
	return false

func getValue(obj, index):
	Util.debug("Requesting "+index+" from",5)
	Util.debug(obj,5)
	var cindex = "~"+index
	if index in obj:
		return obj[index]
	elif cindex in obj:
		var keys = obj[cindex].keys()#.sort_custom(SorterByIndexInt, "sort")
		keys.sort_custom(SorterByIndexInt, "sortInv")
		for key in keys:
			if "condition" in obj[cindex][key]:
				if checkCondition(obj[cindex][key]["condition"]) == true:
					return obj[cindex][key].value
			else:
				return obj[cindex][key].value
	elif obj.has("persist"):
		return getValue(obj.persist,index)
	
	var indexArr = index.split(".")
	if indexArr.size() > 1:
		
		var topObject = getValue(obj,indexArr[0])
		indexArr.remove(0)
		return getValue(topObject,PoolStringArray(indexArr).join("."))
		
	return null

func getValueFromList(list):
	var file = File.new()
	file.open("res://data/list/"+list+".txt", file.READ)
	var entries = []
	var weightTotal = 0
	while !file.eof_reached():
		var csv = file.get_csv_line (";")
		var weight = int(csv[1])
		var entry = {"value":csv[0],"weight":weight}
		entries.append(entry)
		weightTotal += weight
	file.close()
		
	var rand = rng.randi_range(1,weightTotal)
	
	var i = 0
	while(rand > entries[i].weight and i < entries.size()):
		rand -= entries[i].weight
		i += 1
		
	return entries[i].value
	

func getValueFromPath(path):
	var cObj
	var pathArr = path.split(".")
	var i = 0
	#if(pathArr[0] == "PlayerData"): cObj = PlayerData
	#elif(pathArr[0] == "WorldData"): cObj = WorldData
	#elif(pathArr[0].begins_with("NPC")): cObj = getNPC(MiscData["currentNpcId"][int(pathArr[0].substr(3,pathArr[0].length()-3))])
	cObj = getObjectFromPath(pathArr[0])
	i+= 1
	while(i < pathArr.size()):
		cObj = getValue(cObj,pathArr[i])
		i+=1
		
	return cObj

func getObjectFromPath(path):
	if(path == "PlayerData"): return PlayerData
	elif(path == "WorldData"): return WorldData
	elif(path.begins_with("NPC")): return getNPC(MiscData["currentNpcId"][int(path.substr(3,path.length()-3))])
	return null

func setValueAtPath(path,value):
	var cObj
	var pathArr = path.split(".")
	var i = 0
	cObj = getObjectFromPath(pathArr[0])
	i+= 1
	while(i < pathArr.size()-1):
		if !cObj.has(pathArr[i]):
			cObj[pathArr[i]] = {}
		cObj = cObj[pathArr[i]]
		i+=1
		
	cObj[pathArr[i]] = value
	
	
	

func checkCondition(condition):
	if condition.mode == "AND":
		for c in condition.conditions:
			if checkCondition(c) == false:
				return false
		return true
	elif condition.mode == "OR":
		for c in condition.conditions:
			if checkCondition(c) == true:
				return true
		return false
	elif condition.mode == "eq":
		if getValueFromPath(condition["var"]) == condition["val"]:
			return true
	elif condition.mode == "neq":
		if getValueFromPath(condition["var"]) != condition["val"]:
			return true
	
	return false

func loadDialogue(dialogueId):
	var file = File.new()
	file.open("res://data/dialogue/"+dialogueId+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		dialogues[dialogueId] = temp.result

func loadLocation(locationId):
	var file = File.new()
	file.open("res://data/location/"+locationId+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		locations[locationId] = temp.result

func loadMetadata(fileName):
	var file = File.new()
	file.open("res://data/"+fileName+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		return temp.result
	return null
	#TODO: Error handling

func loadNPC(npcId):
	var file = File.new()
	file.open("res://data/npc/"+npcId+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		npcs[npcId] = temp.result
		print("NPC "+npcId+" loaded")
	else:
		print("Error loading NPC "+npcId+": "+str(temp.error))

func loadNPCs():
	print("Start loading NPCs")
	var npcFiles = Util.getFilesInFolder("res://data/npc")
	for npcFile in npcFiles:
		var npcFileParts = npcFile.split(".")
		loadNPC(npcFileParts[0])
	print("Complete loading NPCs")

func newGame():
	MetaData = loadMetadata("ber")
	print(MetaData)
	loadNPCs()
	executeLocation(getLocation(MetaData.startLocation))
	gotoMain()
	
func execute(commands):
	var consume = false
	
	if commands.has("bg"):
		CurrentUi.Bg = commands["bg"]
		
	if commands.has("PlayerData"):
		for key in commands.PlayerData:
			var PlayerDataEntry = commands.PlayerData[key]
			var newValue
			if typeof(PlayerDataEntry) == TYPE_STRING or typeof(PlayerDataEntry) == TYPE_INT:
				newValue = PlayerDataEntry
			
			var pathArr = key.split(".")
			var i = 0
			var cPos = PlayerData
			while i+1<pathArr.size():
				if !cPos.has(pathArr[i]):
					cPos[pathArr[i]] = {}
				cPos = cPos[pathArr[i]]
				i+= 1
			
			cPos[pathArr[i]] = newValue
		
	print("START")
		
	if commands.has("NPCData"):
		for key in commands.NPCData:
			for entry in commands.NPCData[key]:
				setValueAtPath("NPC"+key+".persist."+entry,commands.NPCData[key][entry])
	
	print("REACHED")
		
	if commands.has("goto"):
		var gotoLocation = getLocation(commands["goto"])
		executeLocation(gotoLocation)
		return true
		
	if commands.has("showDialog"):
		var dialog = load("res://scenes/dialog/"+commands.showDialog+".tscn").instance()
		get_tree().get_root().add_child(dialog)
		dialog.popup_centered()
		#dialog.popup()
		
	return consume
	
func parseText(t):
	var textArr = t.split("#")
	if textArr.size() == 1: return t
	
	var textReturn = ""
	var i = 0 
	while i < textArr.size():
		if i%2 == 0:
			textReturn += textArr[i]
		else:
			if textArr[i] == "": #this is an escaped #
				textReturn += "#"
			else:
				textReturn += getValueFromPath(textArr[i])
		i += 1
	return textReturn
	
func executeLocation(location,omitStart=false,updateLocationId=true):
	if !omitStart and location.has("onStart"):
		if execute(location.onStart): return
	
	var bgTemp = getValue(location,"bg")
	if bgTemp != null:
		CurrentUi.Bg  = bgTemp
		
	if location.has("text"):
		if typeof(location["text"]) == TYPE_ARRAY:
			CurrentUi.Text  = PoolStringArray(location["text"]).join("\n")
		else:
			CurrentUi.Text  = location["text"]
		CurrentUi.Text = parseText(CurrentUi.Text)
	else:
		CurrentUi.Text  = ""
		
	CurrentUi.RL.clear()
	if location.has("rl"):
		CurrentUi.ShowRL = true
		for i in location.rl:
			CurrentUi.RL.append(i)
	else:
		CurrentUi.ShowRL = false
	
	
	CurrentUi.NPCs.clear()
	if location.has("npcs") and location.npcs == true:
		for npcId in npcs:
			var npc = getNPC(npcId)
			if npcIsPresent(npc,location.ID):
				CurrentUi.NPCs.append(npc)
	if CurrentUi.NPCs.size() > 0:
		CurrentUi.ShowNPCs = true
	else:
		CurrentUi.ShowNPCs = false
	
	CurrentUi.Actions.clear()
	if location.has("actions"):
		var keys = location.actions.keys()
		keys.sort_custom(SorterByIndexInt, "sortInv")
		for key in keys:
			var action = location.actions[key].duplicate()
			
			if action.has("goto"):
				var actionGotoArr = action.goto.split(".")
				if actionGotoArr[0] == "SELF":
					actionGotoArr[0] = location.SELF
					action.goto = actionGotoArr.join(".")
					
				var targetLocation = getLocation(action.goto)
				if targetLocation.has("bg"):
					call_deferred("preloadTexture",[targetLocation.bg])
				
			if "condition" in action:
				if checkCondition(action["condition"]) == true:
					CurrentUi.Actions.append(action)
			else:
				CurrentUi.Actions.append(action)
		#CurrentUi.Actions = location.actions.duplicate()
	if updateLocationId:
		CurrentUi.LocationId = location.ID
	updateUI()

func npcIsPresent(npc,locationId,time = -1):
	if time == -1: time =  now()
	
	var timeDict = Util.getDateTime(time)
	
	if !npc.has("schedule"): return false
	if !npc.schedule.has(locationId): return false
	
	for presence in npc.schedule[locationId]:
		if timeDict.weekday in presence.days:
			var timeBase100 = timeDict.hour * 100 + timeDict.minute
			if timeBase100 >= presence.timeStart and timeBase100 <= presence.timeEnd: return true
	return false
	

func npcDialog(npc):
	#Util.setDebugLevel(5)
	MiscData.currentNpcId[0] = npc.ID
	
	CurrentUi.ShowNPCDialog = true
	
	var dialogueId = getValue(npc,"dialogue")+".start"
	npcDialogShow(dialogueId)
	
	updateUI()


func getDialogueOption(dialogueId,optionId):
	var dialogue = getDialogue(dialogueId)
	var option = dialogue.options[optionId]
	return npcDialogOptionLink(option)
	
func npcDialogOptionLink(option,linkSelf="DEFAULT"):
	var targetArr = option.target.split(".")
	if targetArr[0] == "SELF": 
		if linkSelf=="DEFAULT": linkSelf=MiscData.currentDialogueID.split(".")[0]
		targetArr[0] = linkSelf
		option.target = targetArr.join(".")
	return option
	
func npcDialogOption(optionId):
	var option = getDialogueOption(MiscData.currentDialogueID,optionId)
	if option.target == "LEAVE": 
		CurrentUi.ShowNPCDialog = false
		updateUI()
		return
		
	npcDialogShow(option.target)
	updateUI()

func npcDialogOptionsUpdate(options):
	var keys = options.keys()
	keys.sort_custom(SorterByIndexInt, "sortInv")
	for key in keys:
		var option = npcDialogOptionLink(options[key])
		if option.has("conditionShow"):
			if !checkCondition(option.conditionShow):
				Util.debug("Condition not valid:",5)
				Util.debug(option.conditionShow,5)
				continue
		var o = {"text":option.text,"ID":key}
		CurrentUi.NPCDialogOption.append(o)

func npcDialogShow(dialogueId):
	MiscData.currentDialogueID = dialogueId
	var dialogue = getDialogue(dialogueId)
	if dialogue.has("onShow"):
		execute(dialogue.onShow)
	npcDialogUpdate(dialogue)

func npcDialogUpdate(dialogue):
		
	CurrentUi.NPCDialog.clear()
	CurrentUi.NPCDialogOption.clear()
	
	var statement = {"charId":MiscData.currentNpcId[0],"text":parseText(dialogue.text)}
	
	CurrentUi.NPCDialog.append(statement)
	
	npcDialogOptionsUpdate(dialogue.options)
	
	

func gotoLocation(locationId,time):
	var gotoLocation = getLocation(locationId)
	timeMove(time)
	executeLocation(gotoLocation)

func gotoMain():
	call_deferred("_deffered_gotoMain")
	
func _deffered_gotoMain():
	return get_tree().change_scene(mainScene)
	
	
func timeMove(t):
	t = int(t)
	WorldData.Time += t
	CurrentUi.Time = now()
	
	for stat in PlayerData.stat:
		PlayerData.stat[stat].current -= PlayerData.stat[stat].decay * t
	
	playerData2UI()


var preloadedTextures = []
var preloadedTexturesMax = 20
func preloadTexture(path):
	if typeof(path) == TYPE_ARRAY: path = path[0]
	preloadedTextures.append(load(path))
	if preloadedTextures.size() > preloadedTexturesMax:
		preloadedTextures.pop_front()

func playerData2UI():
	CurrentUi.PlayerStat = PlayerData.stat
	
func SaveGameLoad():
	var saveGame = File.new()
	if not saveGame.file_exists("user://quicksave.json"):
        return # Error! We don't have a save to load.
	saveGame.open("user://quicksave.json", File.READ)
	var data = parse_json(saveGame.get_line())
	saveGame.close()
	CurrentUi = data.CurrentUi
	PlayerData = data.PlayerData
	WorldData = data.WorldData
	updateUI()
	
func SaveGameSave():
	var data = {}
	data.CurrentUi = CurrentUi
	data.PlayerData = PlayerData
	data.WorldData = WorldData
	var saveGame = File.new()
	saveGame.open("user://quicksave.json", File.WRITE)
	saveGame.store_line(to_json(data))
	saveGame.close()

func recalcUI():
	executeLocation(getLocation(CurrentUi.LocationId),true)
	updateUI()

func updateUI():
	get_tree().call_group("uiUpdate","updateUI",GameManager.CurrentUi)
