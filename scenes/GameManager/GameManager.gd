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
	"ActiveModfiers":{},
	"LocationId":"",
	"NPCs":[],
	"NPCDialog":[],
	"NPCDialogOption":[],
	"ShopItems":[],
	"ShopKeywords":[],
	"ShopShowOwned":false,
	"ShowDetailsPC":false,
	"ShowGameMenu": false,
	"ShowGameStatus":false,
	"ShowPlayerMoney":true,
	"ShowNPCDialog":false,
	"ShowNPCs":false,
	"ShowPlayerStat":true,
	"ShowRL": true,
	"ShowServices":false,
	"ShowShop":false,
	"ShowStatusDetails":false,
	"ShowTime": true,
	"ShowWardrobe":false,
	"ShowWearInformation":false,
	"RL":[],
	"Time":0,
	"UIGroup":"uiUpdate",
	"Services":{"type":"","available":[],"availableCategories":{}},
	"Wardrobe":{
		"seltype":"",
		"selitems":[]
	}
}

var MetaData = {} #does not get saved in savegame

var PlayerData = {
	"ID":"PC",
	"inventory":{},
	"modifier":{},
	"money":10000,
	"name":{"first":"","last":""},
	"skill":{},
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
	},
	"outfit":{
		"CURRENT":{"clothes":"","shoes":"","bra":"","panties":"","coat":"","purse":""}
	}
}

var WorldData = {
	"Time": 0,
	"TimeOffset":0,
	"Weather":"clear",
	"SunPosition":"dawn",
	"Shops":{}
}

var MiscData = {
	currentNpcId = ["","","",""], #0-2: Dialogue, 3: Script calculations
	currentDialogueID = "",
	currentLocationID = "",
	locationStack = []
}

var Preferences = {
	"modsAutoactivate":false,
	"mods":{}
}

var dialogues = {}
var events = {}
var functions = {}
var items = {}
var locations = {}
var misc = {}
var modifiers = {}
var npcs = {}
var services = {}
#var skills = {}

var functionObjects = []

var folderRoot:String setget , getRootFolder
var folderMod:String setget , getModFolder

func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		QUIT()

func _ready():
	get_tree().set_auto_accept_quit(false) # so that we can save preferences
	loadPreferences()
	playerData2UI()
	CurrentUi.Time = WorldData.Time + WorldData.TimeOffset
	rng.randomize()
	randomize()
	
func QUIT():
	print("QUIT")
	savePreferences()
	get_tree().quit()
	

func bodyTexture(bodypart):
	return getValue(PlayerData.body,bodypart+".texture","")
	
func itemWornAtSlot(itemslot):
	var itemId = getValue(PlayerData.outfit.CURRENT,itemslot)
	if itemId == "" or itemId == null or itemId == "naked":
		var texture
		if itemslot == "coat":
			texture = itemWornAtSlot("clothes").texture
		elif itemslot == "clothes":
			texture = itemWornAtSlot("bra").texture
		else:
			texture = bodyTexture(itemslot2bodypart(itemslot))
		var pseudoItem = {"ID":"NAKED","texture":texture}
		return pseudoItem
	return getItem(itemId)

func now():
	var now = WorldData.Time + WorldData.TimeOffset
	return now
	
func getColor(id):
	if !misc.has("colors"): loadMisc()
	if misc.colors.has(id):
		return misc.colors[id]
	return {"name":id,"rgb":"000000"}

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

func getItem(itemId):
	#all items get loaded at startup, no need to load them here
	var item = items[itemId]
	item["ID"] = itemId
	
	if item.has("inherit"):
		
		var parent = getItem(item.inherit)
		item = Util.inherit(item,parent)
	return item	
	
	
func getItemCoveredBodyParts(item):
	if !item.has("parts"): return []
	var result = []
	for partId in item.parts:
		var part = getItempart(partId)
		for cover in part.covers:
			if !result.has(cover): result.append(cover)
	return result

func getItempart(id):
	if !misc.has("itemparts"): loadMisc()
	return misc.itemparts[id]
	
func getLocation(locationId):
	
	var locationArr = locationId.split(".")
	
	
	if !locations.has(locationArr[0]):
		loadLocation(locationArr[0])
	var l = locations[locationArr[0]] 
		
	var i = 1
	while i < locationArr.size():
		if !l.has(locationArr[i]): 
			l["ID"] = locationId
			print("Error loading location: "+locationId)
			return l
		l = l[locationArr[i]]
		i += 1
	
	l["SELF"] = locationArr[0]
	l["ID"] = locationId
	
	if l.has("inherit"):
		var parent = getLocation(l.inherit)
		#l = Util.mergeInto(parent,l)
		l = Util.inherit(l,parent)
	
	return l
	
func getNPC(npcId):
	#all NPCs get loaded at the beginning of the game, no need to load them here
	if npcId == PlayerData.ID:
		return PlayerData
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

func inventoryAdd(item,count=1,ignoreOwned=false):
	if PlayerData.inventory.has(item.ID):
		if !ignoreOwned:
			PlayerData.inventory[item.ID].count += count
	else:
		PlayerData.inventory[item.ID] = {"count":count}
		
func itemPurchase(item,count=1):
	moneySpend(item.price)
	inventoryAdd(item,count)

func itemslot2bodypart(itemslot):
	match itemslot:
		"bra": return "breast"
		"coat": return "torsoOuter"
		"clothes": return "torso"
		"panties": return "lap"
		"purse": return "hand"
		"shoes": return "feet"
		

func hasValue(obj, index):
	if obj.has(index): return true
	var cindex = "~"+index
	if obj.has(cindex): return true
	if obj.has("persist"): return hasValue(obj.persist, index)
	return false

func getValue(obj, index, default = null):
	Util.debug("Requesting "+index+" from",5)
	Util.debug(obj,5)
	if obj == null: return default
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
		return getValue(obj.persist,index,default)
	
	var indexArr = index.split(".")
	if indexArr.size() > 1:
		
		var topObject = getValue(obj,indexArr[0])
		indexArr.remove(0)
		return getValue(topObject,PoolStringArray(indexArr).join("."),default)
		
	return default

func getValueFromList(list):
	var file = File.new()
	file.open("res://data/list/"+list+".txt", file.READ)
	var entries = []
	var weightTotal = 0
	while !file.eof_reached():
		var csv = file.get_csv_line (";")
		if csv.size() == 2:
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
	

func getActiveMods():
	var result = []
	for modID in Preferences.mods:
		if !Util.folderExists(getModFolder(modID)):
			Preferences.mods.erase(modID)
		elif Preferences.mods[modID] == true:
			result.append(modID)
	return result

func getArgumentsFromString(s):
	var result = []
	
	var start = 0
	var end = 0
	var current = 0
	var level = 0
	var endHere
	
	for c in s:
		endHere = true
		if c == "(":
			if level == 0: start += 1
			level += 1
			end = current
		elif c == ")":
			level -= 1
			if level == 0: endHere = false
		elif c == ":" and level == 0:
			result.append(s.substr(start,end-start))
			start = current + 1
		
		current += 1
		if endHere: end = current
	if end > start:
		result.append(s.substr(start,end-start))
	return result

func getValueFromPath(path,default=""):
	if path[0] == "'" and path[path.length()-1] == "'":
		return path.substr(1,path.length()-2)
	
	if path[0] == "?":
		#Call a function
		var functionArr = path.split(":",false,1)
		var functionId = functionArr[0].substr(1,functionArr[0].length()-1)
		#var functionObj = getValueFromPath(functionArr[1])
		#return getValueFromFunction(functionId,functionObj)
		return getValueFromFunction(functionId,functionArr[1])
	
	if default == "": default = path
	
	var pathArr = path.split(".")
	var i = 0
	#if(pathArr[0] == "PlayerData"): cObj = PlayerData
	#elif(pathArr[0] == "WorldData"): cObj = WorldData
	#elif(pathArr[0].begins_with("NPC")): cObj = getNPC(MiscData["currentNpcId"][int(pathArr[0].substr(3,pathArr[0].length()-3))])
	var tObj = getObjectFromPath(pathArr[0])
	var cObj = tObj
	i+= 1
	while(i < pathArr.size()):
		cObj = getValue(cObj,pathArr[i])
		if cObj == null:
			print("ERROR loading "+path)
			return default
		i+=1
		
	return cObj
	
func getFOBJ(index):
	return functionObjects[functionObjects.size()-index]

#func getValueFromFunction(functionId,functionObj):
func getValueFromFunction(functionId,functionParameter):
	var result = null
	if functionId == "INT":
		return int(functionParameter)
	
	var arguments = []
	if typeof(functionParameter) == TYPE_STRING:
		var targuments = getArgumentsFromString(functionParameter)
		for targument in targuments:
			arguments.append(getValueFromPath(targument))
	else:
		arguments.append(functionParameter)
	
	if functionId == "COLORNAME":
		var color = getColor(arguments[0])
		result = color.name
	elif functionId == "SUB":
		var a = float(arguments[0])
		var b = float(arguments[1])
		result = a - b
	elif functionId == "TIME":
		result = Util.time(now(),arguments[0])
	else:
	
		var function = functions[functionId]
		
		#We have to do this here because if function.has("FOBJ"): might require FOBJs to be set up
		arguments.invert()
		for argument in arguments:
			functionObjects.append(argument)
		var argumentCount = arguments.size()
		
		if function.has("FOBJ"):
			for fobj in function.FOBJ:
				arguments.push_front(getValueFromPath(fobj))
		
			#We have to set up FOBJs again because new FOBJs have been added
			for i in range(argumentCount):
				functionObjects.pop_back()
			for argument in arguments:
				functionObjects.append(argument)
			argumentCount = arguments.size()	
		
		
		var resultMode = "standard"
		
		if function.has("resultMode"): resultMode = function.resultMode
		
		if resultMode == "has":
			var condition = {"mode":"has", "target":function.target, "index":""}
			var keys = function.result.keys()
			keys.sort_custom(SorterByIndexInt, "sortInv")
			for key in keys:
				var possibleResult = function.result[key]
				if possibleResult[0] == null:
					result = possibleResult[1]
					break
				condition.index = possibleResult[0]
				if checkCondition(condition):
					result = possibleResult[1]
					break
			
		elif resultMode == "standard":
			var keys = function.result.keys()
			keys.sort_custom(SorterByIndexInt, "sortInv")
			for key in keys:
				var possibleResult = function.result[key]
				if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
					if possibleResult.has("valueCalc"):
						result = parseText(possibleResult.valueCalc)
					elif possibleResult.has("valueRef"):
						result = getValueFromPath(possibleResult.valueRef)
					else:
						result = possibleResult.value
					break
		elif resultMode == "stringConcat":
			result = ""
			var keys = function.result.keys()
			keys.sort_custom(SorterByIndexInt, "sort")
			for key in keys:
				var possibleResult = function.result[key]
				if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
					if possibleResult.has("valueCalc"):
						result += parseText(possibleResult.valueCalc)
					elif possibleResult.has("valueRef"):
						result += str(getValueFromPath(possibleResult.valueRef))
					else:
						result += str(possibleResult.value)
		elif resultMode == "stringFormat":
			result = function.string
			var resultValues = {}
			var keys = function.result.keys()
			for key in keys:
				var possibleResult = function.result[key]
				if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
					if possibleResult.has("valueCalc"):
						resultValues[key] = parseText(possibleResult.valueCalc)
					elif possibleResult.has("valueRef"):
						resultValues[key] = str(getValueFromPath(possibleResult.valueRef))
					else:
						resultValues[key] = str(possibleResult.value)
				else:
					resultValues[key] = ""
			result = result.format(resultValues)
			result = Util.stringFormat(result)
		elif resultMode == "mathAdd":
			result = 0
			var keys = function.result.keys()
			for key in keys:
				var possibleResult = function.result[key]
				if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
					if possibleResult.has("valueCalc"):
						result += float(parseText(possibleResult.valueCalc))
					elif possibleResult.has("valueRef"):
						result += getValueFromPath(possibleResult.valueRef)
					else:
						result += possibleResult.value
						
		for i in range(argumentCount):
			functionObjects.pop_back()
	
	return result
			
	
func getObjectFromPath(path):
	#if(path == "FOBJ"): return functionObjects[functionObjects.size()-1]
	if(path == "FOBJ"): return getFOBJ(1)
	if(path == "MiscData"): return MiscData
	elif(path == "PlayerData"): return PlayerData
	elif(path == "WorldData"): return WorldData
	elif(path == "CurrentUi"): return CurrentUi
	elif(path.begins_with("NPC")): return getNPC(MiscData["currentNpcId"][int(path.substr(3,path.length()-3))])
	#elif(path.begins_with("FOBJ")): return functionObjects[functionObjects.size()-int(path.substr(4,path.length()-4))]
	elif(path.begins_with("FOBJ")): return getFOBJ(int(path.substr(4,path.length()-4)))
	return null

func getModFolder(modID=""):
	if modID=="":
		return getRootFolder()+"/mods"
	return getRootFolder()+"/mods"+"/"+modID

func getRootFolder():
	var path
	if OS.is_debug_build ( ):
		path = "I:/ownCloud/Development/Godot/Ber_folder/ber.exe"
	else:
		path = OS.get_executable_path()
	return Util.folderFromPath(path)

func getServiceById(serviceId):
	var result = services[serviceId]
	result.ID = serviceId
	return result

func getSkill(id):
	return misc.skills[id]

func modValueAtPath(path,mode,value):
	
	
	if mode == "set": 
		setValueAtPath(path,value)
		return
		
	var oldValue = getValueFromPath(path)
	var newValue
	
	if mode == "inc": 
		newValue = oldValue + value
		
	setValueAtPath(path,newValue)

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
	
func shop(arguments):
	
	if !WorldData.has("shops"): WorldData.shops = {}
	if !WorldData.shops.has(arguments.ID): WorldData.shops[arguments.ID] = {"validTil":-1,"items":[]}
	
	if WorldData.shops[arguments.ID].validTil < WorldData.Time:
		var possibleItems = []
		for itemId in items:
			#var item = items[itemId]
			var item = getItem(itemId)
			if item.has("isTemplate") and item.isTemplate == true: continue
			if typeof(arguments.kw) == TYPE_STRING:
				if arguments.kw in item.shopKWs:
					possibleItems.append(itemId)
			elif typeof(arguments.kw) == TYPE_ARRAY or typeof(arguments.kw) == TYPE_STRING_ARRAY:
				for kw in arguments.kw:
					if kw in item.shopKWs:
						possibleItems.append(itemId)
						break
		possibleItems.shuffle()
		var itemCountMax = 20
		var itemCountMin = 10
		if arguments.has("itemCountMax"): itemCountMax = arguments.itemCountMax
		if arguments.has("itemCountMin"): itemCountMin = arguments.itemCountMin
		
		var itemCount = rng.randi_range(itemCountMin,itemCountMax)
		
		if possibleItems.size() > itemCount : possibleItems.resize(itemCount)
		
		WorldData.shops[arguments.ID].items = possibleItems
		
		WorldData.shops[arguments.ID].validTil = GameManager.getValueFromPath(arguments.validTil)
		print(WorldData.shops[arguments.ID].validTil)
	
	CurrentUi.UIGroup = "uiShop"
	CurrentUi.ShowShop = true
	CurrentUi.ShopID = arguments.ID
	shopUpdateItems()
	

func shopClose():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowShop = false
	CurrentUi.ShopItems.clear()
	updateUI()
	
func shopUpdateItems():
	var shopID = CurrentUi.ShopID
	var shopItems = WorldData.shops[shopID].items
	CurrentUi.ShopItems.clear()
	
	for itemId in shopItems:
		#var item = items[itemId]
		var item = getItem(itemId)
		if CurrentUi.ShopShowOwned or !(itemId in PlayerData.inventory):
			CurrentUi.ShopItems.append(item)
			
	updateUI()

func checkCondition(condition):
	var conditionValue
	
	if condition.has("val"):
		conditionValue = condition["val"]
	elif condition.has("valRef"):
		conditionValue = getValueFromPath(condition["valRef"])
	
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
		var valueFromPath = getValueFromPath(condition["var"])
		return Util.equals(conditionValue,valueFromPath)
	elif condition.mode == "neq":
		var valueFromPath = getValueFromPath(condition["var"])
		return !Util.equals(conditionValue,valueFromPath)
	elif condition.mode == "leq":
		var valueFromPath = getValueFromPath(condition["var"])
		return (Util.bigger(conditionValue,valueFromPath) or Util.equals(conditionValue,valueFromPath))
	elif condition.mode == "heq":
		var valueFromPath = getValueFromPath(condition["var"])
		return (Util.bigger(valueFromPath,conditionValue) or Util.equals(conditionValue,valueFromPath))
	elif condition.mode == "has":
		var target = getValueFromPath(condition["target"])
		return target.has(condition["index"])
	
	return false

func loadDialogue(dialogueId):
	var file = File.new()
	file.open("res://data/dialogue/"+dialogueId+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		dialogues[dialogueId] = temp.result

func loadEvent(filePath):
	var file = File.new()
	file.open("res://data/event/"+filePath+".json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		var fitems = temp.result
		for eventId in fitems:
			var event = fitems[eventId]
			event.ID = eventId
			if !events.has(event.listen): events[event.listen] = {}
			events[event.listen][eventId] = event
	else:
		print("Error loading Items from file "+filePath+": "+str(temp.error))

func loadEvents():
	events = {}
	events.timePass = {}
	print("Start loading Events")
	var itemFiles = Util.getFilesInFolder("res://data/event")
	for itemFile in itemFiles:
		var itemFileParts = itemFile.split(".")
		loadEvent(itemFileParts[0])
	print("Complete loading Events")

func loadFunctions():
	print("Start loading Functions")
	var file = File.new()
	file.open("res://data/script/function.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		functions = temp.result
	else:
		print("Error loading Functions :"+str(temp.error))
	print("Complete loading Functions")

func loadItem(filePath):
	var file = File.new()
	#file.open("res://data/item/"+filePath+".json", file.READ)
	file.open(filePath, file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		var fitems = temp.result
		for itemId in fitems:
			var item = fitems[itemId]
			item.ID = itemId
			items[itemId] = item
	else:
		print("Error loading Items from file "+filePath+": "+str(temp.error))

func loadItems(path="res://data"):
	var itemFiles = Util.getFilesInFolder(path+"/item")
	for itemFile in itemFiles:
		#var itemFileParts = itemFile.split(".")
		#loadItem(itemFileParts[0])
		loadItem(path+"/item/"+itemFile)

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

func loadMisc(path="res://data/misc"):
	var miscFiles = Util.getFilesInFolder(path)
	for fname in miscFiles:
		var fnameArr = fname.split(".")
		misc[fnameArr[0]] = Util.loadJSONfromFile(path+"/"+fname)
	
func loadMods():
	for modId in Preferences.mods:
		if Preferences.mods[modId] == true and Util.folderExists(getModFolder(modId)):
			loadItems(getModFolder()+"/"+modId)

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
	var npcFiles = Util.getFilesInFolder("res://data/npc")
	for npcFile in npcFiles:
		var npcFileParts = npcFile.split(".")
		loadNPC(npcFileParts[0])
	
func loadPreferences():
	var preferencesPath = getRootFolder()+"/preferences.json"
	if !Util.fileExists(preferencesPath): savePreferences()
	else:
		var preferencesFromFile = Util.loadJSONfromFile(preferencesPath)
		Preferences = Util.mergeInto(preferencesFromFile,Preferences)
		
func savePreferences():
	var preferencesPath = getRootFolder()+"/preferences.json"
	Util.data2File(Preferences,preferencesPath,true)
	
	
func loadServices():
	var file = File.new()
	file.open("res://data/services/services.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		var fitems = temp.result
		for itemId in fitems:
			var item = fitems[itemId]
			item.ID = itemId
			services[itemId] = item
	else:
		print("Error loading Services: "+str(temp.error))

func logOut(msg,type="NOTICE"):
	get_tree().call_group("logger","logOut",msg,type)

#func loadSkills():
#	var file = File.new()
#	file.open("res://data/misc/skills.json", file.READ)
#	var text = file.get_as_text()
#	file.close()
#	var temp = JSON.parse(text)
#	if temp.error == OK:
#		var fitems = temp.result
#		for itemId in fitems:
#			var item = fitems[itemId]
#			item.ID = itemId
#			#skills[itemId] = item
#	else:
#		print("Error loading Skills: "+str(temp.error))

func reachableLocationLink(rl,linkSelf="DEFAULT"):
	var targetArr = rl.locationId.split(".")
	if targetArr[0] == "SELF": 
		if linkSelf=="DEFAULT": linkSelf=MiscData.currentLocationID.split(".")[0]
		targetArr[0] = linkSelf
		rl.locationId = targetArr.join(".")
	return rl

func continueGame():
	loadConstantData()
	SaveGameLoad()
	gotoMain()

func loadGame(path):
	loadConstantData()
	SaveGameLoad(path)
	gotoMain()
	

func loadConstantData():
	MetaData = loadMetadata("ber")
	if MetaData.has("onLoad"):
		execute(MetaData.onLoad)
	loadEvents()
	loadFunctions()
	loadItems()
	loadMisc()
	loadModifiers()
	loadNPCs()
	loadServices()
	#loadSkills()
	loadMods()

func detailsHide():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowDetailsPC = false
	updateUI()

func detailsShow():
	MiscData.currentNpcId[3] = PlayerData.ID
	
	CurrentUi.UIGroup = "uiDetails"
	CurrentUi.ShowDetailsPC = true
	
	CurrentUi.ActiveModfiers.clear()
	
	for modifierGroupId in PlayerData.modifier:
		CurrentUi.ActiveModfiers[modifierGroupId] = []
		var modifierGroup = modifiers[modifierGroupId]
		for modifierId in modifierGroup:
			var modifier = getModifier(modifierGroupId,modifierId)
			modifier.description = parseText(modifier.description)
			CurrentUi.ActiveModfiers[modifierGroupId].append(modifier)
			
	updateUI()
	
func getModifier(modifierGroupId,modifierID):
	return modifiers[modifierGroupId][modifierID]

func modifiersCalculate(npcId):
	var npc = getNPC(npcId)
	
	if !npc.has("modifier"): npc.modifier = {}
	npc.modifier.clear()
	
	MiscData.currentNpcId[3] = npcId
	
	for modifierGroupId in modifiers:
		var modifierGroup = modifiers[modifierGroupId]
		npc.modifier[modifierGroupId] = []
		for modifierId in modifierGroup:
			var modifier = modifierGroup[modifierId]
			if checkCondition(modifier.condition):
				npc.modifier[modifierGroupId].append(modifierId)
		

func loadModInfo(modId):
	var result = {"name":modId,"description":"","version":0}
	var modDataFile = {}
	var modInfoFile = getModFolder()+"/"+modId+"/info.json"
	
	if Util.fileExists(modInfoFile):
		modDataFile = Util.loadJSONfromFile(modInfoFile)
	
	return Util.mergeInto(modDataFile,result) 

func loadModifiers():
	print("Start loading Modifiers")
	var file = File.new()
	file.open("res://data/script/modifier.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		modifiers = temp.result
	else:
		print("Error loading Modifiers :"+str(temp.error))
	print("Complete loading Modifiers")

func moneySpend(m):
	PlayerData.money = int(max(PlayerData.money-m,0))
	playerData2UI()

func newGame():
	
	loadConstantData()
	executeLocation(getLocation(MetaData.startLocation))
	modifiersCalculate(PlayerData.ID)

	gotoMain()
	
func execute(commands):
	
	var consume = false
	
	if typeof(commands) == TYPE_ARRAY:
		for command in commands:
			if execute(command): consume = true
		return consume
	
	if commands.has("debug"):
		print(str(OS.get_ticks_msec())+":")
		print(commands)
	
	if commands.has("bg"):
		CurrentUi.Bg = commands["bg"]
		
	
	
	for dataContainer in ["PlayerData","MiscData"]:
		if commands.has(dataContainer):
			var command = commands[dataContainer]
			for key in command:
				if typeof(command[key]) == TYPE_DICTIONARY and command[key].has("mode"):
					modValueAtPath(dataContainer+"."+key,command[key].mode,command[key].value)
				else:
					setValueAtPath(dataContainer+"."+key,command[key])
			
	if commands.has("eat"):
		stateInc("hunger",commands.eat.saturation)
	if commands.has("drink"):
		stateInc("thirst",commands.drink.saturation)
		
	if commands.has("playerOutfit"):
		setPlayerOutfit(commands.playerOutfit)
		
	if commands.has("NPCData"):
		for key in commands.NPCData:
			for entry in commands.NPCData[key]:
				setValueAtPath("NPC"+key+".persist."+entry,commands.NPCData[key][entry])
	
	if commands.has("Time"):
		if commands.Time.has("Offset"):
			WorldData.TimeOffset = int(commands.Time.Offset)
			timeUpdate()
		if commands.Time.has("Pass"):
			var Activity = "idle"
			var Duration = 0
			if commands.Time.Pass.has("Activity"):
				Activity = commands.Time.Pass.Activity
			if commands.Time.Pass.has("Duration"):
				Duration = commands.Time.Pass.Duration
			timePass(Duration,Activity)
		
		
	if commands.has("goto"):
		MiscData.currentLocationID = commands["goto"]
		var gotoLocation = getLocation(commands["goto"])
		executeLocation(gotoLocation)
		return true
	
	if commands.has("gotoLocationPop"):
		var locationId = MiscData.locationStack.pop_back()
		return execute({"goto":locationId})
	
	if commands.has("interrupt"):
		MiscData.locationStack.append(MiscData.currentLocationID)
		return execute({"goto":commands.interrupt})
		
	if commands.has("gotoShop"):
		shop(commands.gotoShop)
		return true
		
	if commands.has("services"):
		services(commands.services)
		return true
		
	if commands.has("showWardrobe"):
		wardrobe()
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

func path(p):
	if p.substr(0,7) == "mods://":
		return getModFolder() + "/" + p.substr(7,p.length()-7)
	return p

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
		for rl in location.rl:
			if !rl.has("condition") or checkCondition(rl.condition):
				CurrentUi.RL.append(reachableLocationLink(rl))
	else:
		CurrentUi.ShowRL = false
	
	
	
	CurrentUi.NPCs.clear()
	if location.has("npcs") and location.npcs == true:
		for npcId in npcs:
			var npc = getNPC(npcId)
			if npcIsPresent(npc,location.ID):
				CurrentUi.NPCs.append(npcId)
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

func gameMenuHide():
	CurrentUi.ShowGameMenu = false
	updateUI()
	
func gameMenuShow():
	CurrentUi.ShowGameMenu = true
	updateUI()

func gameStatusHide():
	CurrentUi.ShowGameStatus = false
	updateUI()

func gameStatusShow():
	CurrentUi.ShowGameStatus = true
	updateUI()
	
func gameStatusToggle():
	CurrentUi.ShowGameStatus = !CurrentUi.ShowGameStatus
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
	
	

func gotoLocation(transferInfo):#locationId,time,mode):
	var locationId = getValue(transferInfo,"locationId","start")
	var time = getValue(transferInfo,"time",0)
	var mode = getValue(transferInfo,"mode","walk")
	MiscData.currentLocationID = locationId
	var gotoLocation = getLocation(locationId)
	executeLocation(gotoLocation)
	timePass(time,mode)
	

func gotoMain():
	call_deferred("_deffered_gotoMain")
	
func _deffered_gotoMain():
	return get_tree().change_scene(mainScene)
	
func timePass(t,activity):
	if t <= 0: return
	
	for eventID in events.timePass:
		var event = events.timePass[eventID]
		if event.arguments == "*" or Util.isInStr(activity,event.arguments):
			var chanceToHappen = 1 # without mtth the event will happen no matter what
			if event.has("mtth"):
				chanceToHappen = 1-pow(1-(1/event.mtth),t/60)
			if chanceToHappen >= rng.randf():
				execute(event.actions)
				
	for stat in PlayerData.stat:
		PlayerData.stat[stat].current -= PlayerData.stat[stat].decay * t
	
	var hoursToCalc = Util.getHoursTilTime(now(),t+now())
	var daysToCalc = Util.getDaysTilDate(now(),t+now(),false)
	
	if hoursToCalc > 0:
		if events.has("timePass_HOUR"):
			
			for eventID in events.timePass_HOUR: 
				var event = events.timePass_HOUR[eventID]
				for i in range(hoursToCalc):
					execute(event.actions)
					
	if daysToCalc > 0:
		if events.has("timePass_DAY"):
			for eventID in events.timePass_DAY: 
				var event = events.timePass_DAY[eventID]
				for i in range(daysToCalc):
					execute(event.actions)
				
	timeMove(t)
	
	
		
func timeMove(t):
	#meant for internal use, most modules might want to call timePass()
	t = int(t)
	WorldData.Time += t
	#CurrentUi.Time = now()
	timeUpdate()
	#playerData2UI()

func timeUpdate():
	WorldData.TimeDict = Util.getDateTime(now())

var preloadedTextures = []
var preloadedTexturesMax = 20
func preloadTexture(path):
	if typeof(path) == TYPE_ARRAY: path = path[0]
	preloadedTextures.append(load(path))
	if preloadedTextures.size() > preloadedTexturesMax:
		preloadedTextures.pop_front()

func playerData2UI():
	CurrentUi.PlayerStat = PlayerData.stat
	CurrentUi.money = PlayerData.money
	#CurrentUi.Wardrobe.coutfit = PlayerData.outfit.CURRENT
	
func SaveGameLoad(path = "user://quicksave.json"):
	var saveGame = File.new()
	if not saveGame.file_exists(path):
        return # Error! We don't have a save to load.
	saveGame.open(path, File.READ)
	var data = parse_json(saveGame.get_line())
	saveGame.close()
	CurrentUi = data.CurrentUi
	MiscData = data.MiscData
	PlayerData = data.PlayerData
	WorldData = data.WorldData
	
	for npcID in data.NPC:
		if npcID in npcs:
			npcs[npcID].persist = data.NPC[npcID]
	
	updateUI()
	
	logOut("Game loaded from \""+path+"\"")
	
func SaveGameSave(path="user://quicksave.json"):
	var data = {}
	data.CurrentUi = CurrentUi
	data.MiscData = MiscData
	data.PlayerData = PlayerData
	data.WorldData = WorldData
	
	data.NPC = {}
	for npcID in npcs:
		if npcs[npcID].has("persist"):
			data.NPC[npcID] = npcs[npcID].persist
	
	var saveGame = File.new()
	saveGame.open(path, File.WRITE)
	saveGame.store_line(to_json(data))
	saveGame.close()
	
	logOut("Game saved at \""+path+"\"")

func recalcUI():
	executeLocation(getLocation(CurrentUi.LocationId),true)
	updateUI()

func updateUI():
	playerData2UI()
	get_tree().call_group(CurrentUi.UIGroup,"updateUI",CurrentUi)


func wardrobe():
	CurrentUi.UIGroup = "uiWardrobe"
	CurrentUi.ShowWardrobe = true
	CurrentUi.ShowWearInformation = true
	updateUI()
	
func wardrobeClose():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowWardrobe = false
	CurrentUi.Wardrobe.selitems.clear()
	updateUI()
	
func wardrobeUpdateItems():
	CurrentUi.Wardrobe.selitems.clear()
	for itemId in PlayerData.inventory:
		var item = getItem(itemId)
		if item.type == CurrentUi.Wardrobe.seltype:
			CurrentUi.Wardrobe.selitems.append(item)
	updateUI()

func setPlayerOutfit(playerOutfit):
	var itemKeys = items.keys()
	itemKeys.shuffle()
	for itemType in playerOutfit:
		var playerOutfitItem = playerOutfit[itemType]
		for itemId in itemKeys:
			var item = getItem(itemId)
			if item.has("isTemplate") and item.isTemplate == true: continue
			if item.type != itemType: continue
			
			var matched = true
			
			for filterId in playerOutfitItem:
				
				if !item.has(filterId): 
					matched = false
					break
					
				var filterTarget = playerOutfitItem[filterId]
				match typeof(filterTarget):
					TYPE_ARRAY, TYPE_REAL_ARRAY, TYPE_INT_ARRAY:
						if filterTarget.size() == 2 and Util.isNumber(filterTarget[0]) and Util.isNumber(filterTarget[1]): # a range
							if item[filterId] < filterTarget[0] or item[filterId] < filterTarget[0]:
								matched = false
								break
					TYPE_STRING, TYPE_INT, TYPE_BOOL, TYPE_REAL:
						if !Util.equals(item[filterId],filterTarget):
							matched = false
							break
							
			if matched == true:
				inventoryAdd(item,1,true)
				setItemWorn(item)
				break
			
		pass
	
func setItemWorn(item):
	PlayerData.outfit.CURRENT[item.type] = item.ID
	playerData2UI()
	updateUI()

func serviceBuy(serviceId):
	var service = getServiceById(serviceId)
	var duration = 0
	var activity = "idle"
	if service.has("time"): duration = service.time
	timePass(duration,activity)
	if service.has("price"): moneySpend(service.price)
	if service.has("effects"): execute(service.effects)

func services(type):
	CurrentUi.UIGroup = "uiServices"
	CurrentUi.ShowServices = true
	CurrentUi.Services.type = type
	CurrentUi.Services.category = ""
	
	CurrentUi.Services.available.clear()
	CurrentUi.Services.availableCategories.clear()
	
	for serviceId in services:
		var service = services[serviceId]
		if type in service.available:
			CurrentUi.Services.available.append(serviceId)
			if !CurrentUi.Services.availableCategories.has(service.category):
				CurrentUi.Services.availableCategories[service.category] = {"ID":service.category,"label":service.category,"texture":service.texture}
	updateUI()

func servicesClose():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowServices = false
	#CurrentUi.Wardrobe.selitems.clear()
	updateUI()
	
func stateInc(index,value):
	stateSet(index, PlayerData.stat[index].current + value)
	
func stateSet(index,value):
	value = min(max(value,0),10000)
	PlayerData.stat[index].current = value
	
func undress(slot):
	PlayerData.outfit.CURRENT[slot] = ""
	playerData2UI()
	updateUI()