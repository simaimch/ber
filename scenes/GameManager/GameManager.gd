extends Control

class SorterByIndexInt:
	static func sort(a, b):
		if int(a) < int(b):
			return true
		return false
		
	static func sortInv(a ,b):
		return sort(b,a)

class SorterByPriorityInt:
	static func sort(a,b):
		if typeof(a) != TYPE_DICTIONARY:
			return true
		if typeof(b) != TYPE_DICTIONARY:
			return false
		if !a.has("priority"):
			return true
		if !b.has("priority"):
			return false
		if int(a.priority) < int(b.priority):
			return true
		return false

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
	"ShowDetailsNPC":false,
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
	"StatusMods":[],
	"Time":0,
	"UIGroup":"uiUpdate",
	"UIGroupStack":[],
	"Services":{"type":"","available":[],"availableCategories":{}},
	"Wardrobe":{
		"seltype":"",
		"selitems":[]
	}
}

var MetaData = {} #does not get saved in savegame

var PlayerData = {
	"ID":"PC",
	"groups":[],
	"inventory":{},
	"modifier":{},
	"money":10000,
	"name":{"first":"","last":""},
	"skill":{},
	"stat":{
		"hunger":{
			"current":10000,
			"decay":0.2,
			"decaySleep": 0.1
		},
		"thirst":{
			"current":10000,
			"decay":0.3,
			"decaySleep": 0.1
		},
		"sleep":{
			"current":10000,
			"decay":0.15,
			"decaySleep": -0.35
		}
	},
	"outfit":{
		"CURRENT":{"clothes":"","shoes":"","bra":"","panties":"","coat":"","purse":""}
	}
}

var WorldData = {
	"Time": 0,
	"TimeOffset":0,
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
	"mods":{},
	"weatherForecastSize":5
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
var temp = {}
var themes = {}
#var skills = {}

var functionParameters = []
#var functionObjects = []

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
	
func commandLine(c:String)->void:
	if c[0] == "°":
		logOut([checkConditionString(c.substr(1,c.length()-1))])
		return
	
	var cParts = c.split("=")
	if cParts.size() == 1:
		logOut(getValueFromPath(c))
	elif cParts.size() == 2:
		setValueAtPath(cParts[0],JSON.parse(cParts[1]).result)

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

	if !dialogues.has(dialogueId):
		loadDialogue(dialogueId)
	return dialogues[dialogueId]


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
		for cover in getValue(part,"covers",[]):
			if !result.has(cover): result.append(cover)
	return result

func getItempart(id):
	if !misc.has("itemparts"): loadMisc()
	if !misc.itemparts.has(id): 
		logOut("Error loading itempart: "+id)
		return {}
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
			logOut("Error loading location: "+locationId)
			return l
		l = l[locationArr[i]]
		i += 1
	
	l["SELF"] = locationArr[0]
	l["ID"] = locationId
	
	l = locationInherit(l)
	
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
	var findex = "%"+index
	var lindex = ">"+index
	var rindex = "#"+index
	var ranindex="|"+index
	if obj.has(cindex): return true
	if obj.has(findex): return true
	if obj.has(lindex): return true
	if obj.has(rindex): return true
	if obj.has("persist"): return hasValue(obj.persist, index)
	
	var indexArr = index.split(".")
	if indexArr.size() > 1:
		
		var topObject = getValue(obj,indexArr[0])
		indexArr.remove(0)
		return hasValue(topObject,PoolStringArray(indexArr).join("."))
		
	return false

func getValue(obj, index, default = null):
	
	if obj == null: return default
	
	if index in obj:
		return obj[index]
	
	var cindex = "~"+index # pick first entry with valid condition
	var findex = "%"+index # compute using a function
	var lindex = ">"+index # use a list
	var mindex = "&"+index # it's math
	var rindex = "#"+index # the value is a reference, look it up
	var ranindex="|"+index # the value is taken from a random list
	var sindex = "^"+index # the value is a string that needs to be parsed
	
	
	if cindex in obj:
		var keys = obj[cindex].keys()#.sort_custom(SorterByIndexInt, "sort")
		keys.sort_custom(SorterByIndexInt, "sortInv")
		for key in keys:
			if "condition" in obj[cindex][key]:
				if checkCondition(obj[cindex][key]["condition"]) == true:
					#return obj[cindex][key].value
					return getValue(obj[cindex][key],"value")
			else:
				#return obj[cindex][key].value
				return getValue(obj[cindex][key],"value")
	elif obj.has(findex):
		match typeof(obj[findex]):
			TYPE_STRING:
				var functionArr = obj[findex].split(":",false,1)
				var functionId = functionArr[0].substr(1,functionArr[0].length()-1)
				if functionArr.size() > 1:
					return getValueFromFunction(functionId,functionArr[1])
				else:
					var result = getValueFromFunction(functionId)
					return result
			TYPE_DICTIONARY:
				return functionExecute(obj[findex],functionParameters.back())
	elif obj.has(lindex):
		return getValueFromList(obj[lindex])
	elif obj.has(mindex):
		return getValueFromEquation(obj[mindex])
	elif obj.has(rindex):
		return getValueFromPath(obj[rindex])
	elif obj.has(ranindex):
		var options = obj[ranindex]
		match typeof(options):
			TYPE_ARRAY:
				return getValueFromRandom(options)
			TYPE_DICTIONARY:
				return getValueFromRandom(options.values())
	elif obj.has(sindex):
		return parseText(obj[sindex])
	elif obj.has("persist"):
		var persistValue = getValue(obj.persist,index)
		if persistValue: return persistValue
	
	var indexArr = index.split(".")
	if indexArr.size() > 1:
		
		var topObject = getValue(obj,indexArr[0])
		indexArr.remove(0)
		return getValue(topObject,PoolStringArray(indexArr).join("."),default)
		
	return default

func getValueFromList(list,default = null):
	var filePath = "res://data/list/"+list+".txt"
	
	if !Util.fileExists(filePath):
		logOut(["List not found: ",list],"ERROR")
		return default
	
	var file = File.new()
	file.open(filePath, file.READ)
	var entries = []
	#var weightTotal = 0
	while !file.eof_reached():
		var csv = file.get_csv_line (";")
		if csv.size() == 2:
			var weight = int(csv[1])
			var entry = {"value":csv[0],"weight":weight}
			entries.append(entry)
			#weightTotal += weight
	file.close()
	
	return getValueFromRandom(entries)
	#var rand = rng.randi_range(1,weightTotal)
	
	#var i = 0
	#while(rand > entries[i].weight and i < entries.size()):
	#	rand -= entries[i].weight
	#	i += 1
		
	#return entries[i].value
	
func getValueFromRandom(entries:Array):
	var weightTotal = 0
	var validEntries = []
	for entry in entries:
		var condition = getValue(entry,"condition")
		if !condition or checkCondition(condition):
			var weight = getValue(entry,"weight",1)
			weightTotal+=weight
			validEntries.append(entry)
			
	var rand = rng.randi_range(1,weightTotal)
	var i = 0
	while(i < validEntries.size()):
		var weight = getValue(validEntries[i],"weight",1)
		if rand <= weight:
			break
		rand -= weight
		i += 1
		
	return entries[i].value
	
func getWeather(id):
	if !misc.has("weather"): loadMisc()
	match typeof(id):
		TYPE_STRING:
			if misc.weather.has(id):
				var weather = misc.weather[id]
				if weather.has("inherit"):
					var parent = getWeather(weather.inherit)
					weather = Util.inherit(weather,parent)
				return weather
		TYPE_ARRAY, TYPE_STRING_ARRAY:
			var result = []
			for subid in id:
				result.append(getWeather(subid))
			return result
		var idtype:
			logOut(["getWeather: unexpected type of id:",idtype],"ERROR")
	return {}


func getAction(id:String)->Dictionary:
	if !misc.actions.has(id):
		logOut("Action "+str(id)+" not found!","ERROR")
		return {}
	var action = misc.actions[id]
	return linkAction(action)

func linkAction(action:Dictionary)->Dictionary:
	var parentActionId = getValue(action,"inherit",null)
	
	if parentActionId != null: 
		var parentAction = getAction(parentActionId)
		action = Util.inherit(action,parentAction)
	
	return linkObject(action)

func linkObject(object:Dictionary)->Dictionary:
	var conditionalObject = getValue(object,"value",null)
	if conditionalObject != null: object = Util.inherit(conditionalObject,object)
	return object

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

func pathArrayParase(path):
	var arraySignOpenPos = path.find("[")
	
	if arraySignOpenPos >= 0:
		var currentPos = arraySignOpenPos + 1
		var nextArrayOpen
		var nextArrayClose
		var arraySignClosePos
		
		var counter = 0
		
		while counter < 50:
			nextArrayOpen = path.find("[",currentPos)
			nextArrayClose = path.find("]",currentPos)
			
			if nextArrayOpen == -1:
				arraySignClosePos = nextArrayClose
				break
			elif nextArrayClose == -1:
				logOut("Path Array malformed","ERROR")
				return path
			elif nextArrayOpen < nextArrayClose:
				arraySignOpenPos = nextArrayOpen
				currentPos = nextArrayOpen + 1
			else:
				arraySignClosePos = nextArrayClose
				break
			counter+= 1
				
		var innerString = Util.stringSubstrFromTo(path,arraySignOpenPos+1,arraySignClosePos-1)
		var innerValue = str(getValueFromPath(innerString,0))
		
		path = Util.stringReplace(path,arraySignOpenPos,arraySignClosePos,"."+innerValue)
				
		return pathArrayParase(path)
	return path

func getValueFromPath(path,default=""):
	var result = default
	if str(default) == "": result = path
	
	if path.length() == 0: return default
	
	if path.length() >= 2 and path[0] == "'" and path[path.length()-1] == "'": #it's a literal string
		return path.substr(1,path.length()-2)
	
	if path.length() >= 3:
		if path[1] == "'" and path[0] == "i" and path[path.length()-1] == "'": #it's a literal integer
			return int(path.substr(2,path.length()-3))
			
		if path[1] == "'" and path[0] == "f" and path[path.length()-1] == "'": #it's a literal float
			return float(path.substr(2,path.length()-3))
	
	if path[0] in ["0","1","2","3","4","5","6","7","8","9"]:
		if path.find(".") == -1:
			return int(path)
		else:
			return float(path)
			
	if path == "false": return false
	if path == "true": return true
			
			
	path = pathArrayParase(path)
		
	
	if path[path.length()-1] == ")":
		var paramStart = path.find("(")
		if paramStart == -1:
			logOut(["Path malformed:",path],"ERROR")
			return result
		elif paramStart == 0:
			return getValueFromPath(path.substr(1,path.length()-2),default)
		else:
			var functionId = path.substr(0,paramStart)
			var params = path.substr(paramStart+1,path.length()-paramStart-2)
			return getValueFromFunction(functionId,params)
	
	
	
	var pathArr = path.split(".")
	var i = 0
	
	var tObj = getObjectFromPath(pathArr[0])
	var cObj = tObj
	i+= 1
	while(i < pathArr.size()):
		cObj = getValue(cObj,pathArr[i])
		if cObj == null:
			if str(default) == "": logOut("ERROR loading "+path+" in "+str(tObj),"ERROR")
			return result
		i+=1
		
	return cObj
	
#func getFOBJ(index):
	#return functionObjects[functionObjects.size()-index]

func getValueFromEquation(equation:String):
	var result
	
	var regex_dict = {}
	
	#var regex_whitespace = "\\s*"
	regex_dict["ws"] = "\\s*"
	#var regex_bracket_open = "\\("
	regex_dict["bo"] = "\\("
	var regex_bracket_close = "\\)"
	regex_dict["bc"] = "\\)"
	var regex_operator = "[\\-\\+\\*\\/]"
	regex_dict["op"] = "[\\-\\+\\*\\/]"
	var rBrackets = "{ws}{bo}{ws}{op}{ws}([^{bc}{bo}]+){ws}{bc}{ws}" # \s*\(\s*([^\)\(]+)\s*\)\s*
	rBrackets = rBrackets.format(regex_dict)
	
	var regex_brakcets = Util.regex(rBrackets)
	
	result = regex_brakcets.search(equation)
	
	if result:
		#print("Brackets:"+equation)
		var result_start = result.get_start()
		var result_end = result.get_end()
		
		var result_strings = result.get_strings()
		var result_string = result_strings[1]
		
		var valueInBrackets = str(getValueFromEquation(result_string))
		
		equation = Util.stringEraseFromTo(equation,result_start,result_end)
		equation = equation.insert(result_start,valueInBrackets)
		return getValueFromEquation(equation)
	
	#var regex_addsub = "+-"
	regex_dict["opAS"] = "[+-]"
	regex_dict["ref"] =  "[^{bc}{bo}]+|\\w+{bo}.*{bc}".format(regex_dict)
	
	var rAddition = "{ws}({ref}){ws}({opAS}){ws}({ref}){ws}" 
	rAddition = rAddition.format(regex_dict)
	
	
	var regex_addition = Util.regex(rAddition)
	result = regex_addition.search(equation)
	
	if result:
		#print("Addition:"+equation)
		var result_start = result.get_start()
		var result_end = result.get_end()
		
		var result_strings = result.get_strings()
		var result_ns1 = result_strings[1]
		var result_ns2 = result_strings[3]
		
		var n1 = float(getValueFromEquation(result_ns1))
		var n2 = float(getValueFromEquation(result_ns2))
		
		var result_op = result_strings[2]
		
		var mathResult = 0
		
		match result_op:
			"+": mathResult = n1+n2
			"-": mathResult = n1-n2
		
		#print("Add Result:"+str(mathResult))
		
		equation = Util.stringEraseFromTo(equation,result_start,result_end)
		equation = equation.insert(result_start,str(mathResult))
		
		#print("New Eq:"+equation)
		
		return getValueFromEquation(equation)
	
	regex_dict["opMD"] = "[*\\/]"
	
	var rMult = "{ws}({ref}){ws}({opMD}){ws}({ref}){ws}" 
	rMult = rMult.format(regex_dict)
	
	var regex_mult = Util.regex(rMult)
	result = regex_mult.search(equation)
	
	if result:
		#print("Mult:"+equation)
		var result_start = result.get_start()
		var result_end = result.get_end()
		
		var result_strings = result.get_strings()
		var result_ns1 = result_strings[1]
		var result_ns2 = result_strings[3]
		
		var n1 = float(getValueFromEquation(result_ns1))
		var n2 = float(getValueFromEquation(result_ns2))
		
		var result_op = result_strings[2]
		
		var mathResult = 0
		
		match result_op:
			"*": mathResult = n1*n2
			"/": mathResult = n1/n2
		
		#print("Mult Result:"+str(mathResult))
		
		equation = Util.stringEraseFromTo(equation,result_start,result_end)
		equation = equation.insert(result_start,str(mathResult))
		
		#print("New Eq:"+equation)
		
		return getValueFromEquation(equation)
			
	#print("Not found:"+equation)
	result = getValueFromPath(equation)
	#print("Result:"+str(result))
	return result

func getValueFromFunction(functionId,functionParameter=null):
	var currentParameters = []
	
	match typeof(functionParameter):
		TYPE_STRING:
			var parameters = functionParameter.split(",")
			for parameter in parameters:
				var parameterValue = getValueFromPath(parameter)
				currentParameters.append(parameterValue)
		TYPE_ARRAY, TYPE_STRING_ARRAY, TYPE_INT_ARRAY:
			currentParameters = functionParameter
		TYPE_NIL:
			pass
		_:
			currentParameters.append(functionParameter)
	
		
	var result
	
	match functionId:
		"AGE":
			result = Util.getAge(now(),currentParameters[0])
		_:
			var function = getFunction(functionId)
			result = functionExecute(function,currentParameters)
	
	return result
	

func getValueFromFunctionOld(functionId,functionParameter=""):
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
	
	match functionId:
		"COLORNAME":
			var color = getColor(arguments[0])
			result = color.name
		"SUB":
			var a = float(arguments[0])
			var b = float(arguments[1])
			result = a - b
		"TIME":
			result = Util.time(now(),arguments[0])
		_:
			var function = functions[functionId]
			result = functionExecute(function,arguments)
	
	return result

func functionExecute(function:Dictionary,currentParameters=[]):
	var result = null
	
	var paramTypes = getValue(function,"paramTypes",null)
	if paramTypes:
		match typeof(paramTypes):
			TYPE_ARRAY:
				for i in range(paramTypes.size()):
					if i >= currentParameters.size():
						match paramTypes[i]:
							"BOOL":
								currentParameters[i] = false
							"FLOAT":
								currentParameters[i] = 0.0
							"INT":
								currentParameters[i] = 0
							"STRING":
								currentParameters[i] = ""
			var typeParamTypes:
				logOut(["Unknown type of paramTypes ",typeParamTypes, " in ",function],"ERROR")
			
	functionParameters.append(currentParameters)		
	
	var paramsInFunction = getValue(function,"params",null)
	if paramsInFunction:
		match typeof(paramsInFunction):
			TYPE_DICTIONARY:
				var paramKeys = paramsInFunction.keys()
				for paramKey in paramKeys:
					var index = int(paramKey)-1
					var value = getValue(paramsInFunction[paramKey],"value")
					#currentParameters = Util.arraySetAtIndex(currentParameters,index,value)
					functionParameters[functionParameters.size()-1] = Util.arraySetAtIndex(functionParameters[functionParameters.size()-1],index,value)
			var typeParams:
				logOut(["Unknown type of params ",typeParams, " in ",function],"ERROR")
	
	
	
	
	var value = getValue(function,"value",null)
	
	if value:
		result = value
	else:
	
		var resultMode = getValue(function,"resultMode","standard")
		var results = getValue(function,"result",{})
		
		match resultMode:
			"mathAdd":
				result = 0
				var keys = results.keys()
				for key in keys:
					var possibleResult = results[key]
					if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
						result += getValue(possibleResult,"value")
			"standard":
				match typeof(results):
					TYPE_DICTIONARY:
						var keys = results.keys()
						keys.sort_custom(SorterByIndexInt, "sortInv")
						for key in keys:
							var possibleResult = results[key]
							if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
								result = getValue(possibleResult,"value")
								break
					_:
						result = results
			"stringConcat":
				result = ""
				var keys = results.keys()
				keys.sort_custom(SorterByIndexInt, "sort")
				for key in keys:
					var possibleResult = results[key]
					if !possibleResult.has("condition") or checkCondition(possibleResult.condition):
						result += str(getValue(possibleResult,"value",""))
						#TODO: parse?
			_:
				logOut(["ResultMode ",resultMode," not supported in functionExecute"],"ERROR")
		
	functionParameters.pop_back()
	
	if getValue(function,"stringFormat",false) == true:
		result = Util.stringFormat(result)
	
	return result

func functionExecuteOld(function,arguments=[]):
	logOut("Use of functionExecute is deprecated")
	var result = null
	#We have to do this here because if function.has("FOBJ"): might require FOBJs to be set up
	arguments.invert()
	for argument in arguments:
		pass
		#functionObjects.append(argument)
	var argumentCount = arguments.size()
	
	if function.has("FOBJ"):
		for fobj in function.FOBJ:
			arguments.push_front(getValueFromPath(fobj))
	
		#We have to set up FOBJs again because new FOBJs have been added
		for i in range(argumentCount):
			#functionObjects.pop_back()
			pass
		for argument in arguments:
			#functionObjects.append(argument)
			pass
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
	elif resultMode == "stringParse":
		result = parseText(function.string)
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
		#functionObjects.pop_back()
		pass
	
	return result

func functionParameter(pID:int):
	var currentParameterSet = functionParameters.back()
	if pID >= currentParameterSet.size():
		logOut(["Invalid Function Parameter ID:",pID],"ERROR")
		return null
	return currentParameterSet[pID]
	
	
func getObjectFromPath(path):
	if(path == "MiscData"): return MiscData
	elif(path == "Misc"): return misc
	elif(path == "PlayerData"): return PlayerData
	elif(path == "TEMP"): return temp
	elif(path == "WorldData"): return WorldData
	elif(path == "CurrentUi"): return CurrentUi
	#elif(path.begins_with("NPC")): return getNPC(MiscData["currentNpcId"][int(path.substr(3,path.length()-3))])
	elif(path.begins_with("PARAM")): return functionParameter(int(path.substr(5,path.length()-5))-1)
	return null

func getModFolder(modID=""):
	if modID=="":
		return getRootFolder()+"/mods"
	return getRootFolder()+"/mods"+"/"+modID

func getRL(id):
	if !misc.has("rl"): loadMisc()
	if misc.rl.has(id):
		return misc.rl[id]
	return {}

func getRootFolder():
	var path
	if OS.is_debug_build ( ):
		path = "I:/ownCloud/Development/Godot/Ber_folder/ber.exe"
	else:
		path = OS.get_executable_path()
	return Util.folderFromPath(path)

func getServiceById(serviceId):
	if !services.has(serviceId):
		logOut(["Service ",serviceId," not found"],"ERROR")
		return {"ID":serviceId}
	
	var result = services[serviceId]
	result.ID = serviceId
	
	if result.has("inherit"):
		var parent = getServiceById(result.inherit)
		result = Util.inherit(result,parent)
		
	return result

func getSkill(id):
	return misc.skills[id]

func getTheme(id,subId="main"):
	if themes.has(id) and themes[id].has(subId): return themes[id][subId]
	logOut(["Theme not found: ",id,"/",subId],"ERROR")
	return Theme.new()

func modValueAtPath(path,mode,value):
	
	
	if mode == "set": 
		setValueAtPath(path,value)
		return
		
	var oldValue = getValueFromPath(path)
	var newValue

	match mode:
		"inc": 
			newValue = oldValue + value
			setValueAtPath(path,newValue)
		"dec": 
			newValue = oldValue - value
			setValueAtPath(path,newValue)
		"append":
			oldValue.append(value)
		
	

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
		
		WorldData.shops[arguments.ID].validTil = WorldData.Time+180#todo
		print(WorldData.shops[arguments.ID].validTil)
	
	CurrentUi.UIGroup = "uiShop"
	CurrentUi.ShowShop = true
	CurrentUi.ShowWearInformation = true
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
		if CurrentUi.get("ShopShowOwned",false) or !(itemId in PlayerData.inventory):
			CurrentUi.ShopItems.append(item)
			
	updateUI()

func sleep(mode=""):
	var sleepTime:int = 0
	
	var sleepRegen:float = getValueFromPath("PlayerData.stat.sleep.decaySleep",-0.1)
	var sleepNeeded:float = 10000 - getValueFromPath("PlayerData.stat.sleep.current",0)
	var sleepToRegen:int = sleepNeeded / -sleepRegen
	var maxSleep:int = ceil(sleepToRegen) + 14400
	
	if mode == "alarm" and getValueFromPath("PlayerData.alarmclock.enabled",false) == true:
		var alarmTimeStr = getValueFromPath("PlayerData.alarmclock.time","0:00")
		var alarmTimeDict = Util.time(now(),alarmTimeStr)
		sleepTime = ceil(Util.getSecondsTil(now(),alarmTimeDict))
	else:
		sleepTime = sleepToRegen
		
	
	# Hunger
	var sleepDecayHunger:float = getValueFromPath("PlayerData.stat.hunger.decaySleep",0.1)
	var maxHungerIncrease:float = getValueFromPath("PlayerData.stat.hunger.current",2000) - 1000
	var maxSleepHunger:int = ceil(maxHungerIncrease / sleepDecayHunger)
	
	var sleepDecayThirst = getValueFromPath("PlayerData.stat.thirst.decaySleep",0.1)
	var maxThirstIncrease:float = getValueFromPath("PlayerData.stat.thirst.current",2000) - 1000
	var maxSleepThirst:int = ceil(maxThirstIncrease / sleepDecayThirst)
	
	
	var sleepEnd = "healthy"
	var sleepTimeInt:int = 0
	match int(min(min(maxSleepHunger,maxSleepThirst),min(maxSleep,sleepTime))):
		maxSleep:
			sleepTimeInt = sleepToRegen+rand_range(3600,10800)
			sleepEnd = "early"
		maxSleepHunger:
			sleepTimeInt = maxSleepHunger
			sleepEnd = "hunger"
		maxSleepThirst:
			sleepTimeInt = maxSleepThirst
			sleepEnd = "thirst"
		var x:
			sleepTimeInt = sleepTime
			sleepEnd = "healthy"
			logOut(str(x))
			logOut(str(maxSleep))
	 
	logOut("Sleeping time: "+str(sleepTimeInt))
	timePass(sleepTimeInt,"sleep")
	eventArgumentExecute("sleepEnd",sleepEnd,sleepTimeInt)

func checkCondition(condition) -> bool:
	
	match typeof(condition):
		TYPE_STRING:
			return checkConditionString(condition)
		TYPE_ARRAY, TYPE_STRING_ARRAY:
			for subCondition in condition:
				if !checkCondition(subCondition): return false
			return true
		TYPE_DICTIONARY:
			pass
		TYPE_BOOL:
			return condition
		TYPE_NIL:
			return false
		var typeCondition:
			logOut(["Unsuported condition of type ",typeCondition,":",condition],"ERROR")
			return false
	
	
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
		var valueFromPath = getValueFromPath(condition["var"],null)
		return Util.equals(conditionValue,valueFromPath)
	elif condition.mode == "neq":
		var valueFromPath = getValueFromPath(condition["var"],null)
		return !Util.equals(conditionValue,valueFromPath)
	elif condition.mode == "leq":
		var valueFromPath = getValueFromPath(condition["var"],0)
		return (Util.bigger(conditionValue,valueFromPath) or Util.equals(conditionValue,valueFromPath))
	elif condition.mode == "heq":
		var valueFromPath = getValueFromPath(condition["var"],0)
		return (Util.bigger(valueFromPath,conditionValue) or Util.equals(conditionValue,valueFromPath))
	elif condition.mode == "has":
		var target = getValueFromPath(condition["target"])
		return target.has(condition["index"])
	elif condition.mode == "in":
		var valueFromPath = getValueFromPath(condition["var"],null)
		match typeof(conditionValue):
			TYPE_ARRAY:
				return conditionValue.has(valueFromPath)
			var conType:
				logOut(["Unexpected type of condition.val ",conType," in ",condition],"ERROR")
				return false
	elif condition.mode == "timeBetween":
		var timeFromPath = getValueFromPath(condition["var"],null) # most likely now aka WorldData.TimeDict
		match typeof(conditionValue):
			TYPE_DICTIONARY:
				var timeStart = getValue(conditionValue,"start",0)
				var timeEnd = getValue(conditionValue,"end",0)
				
				timeStart = Util.string2DateTime(timeStart)
				timeEnd = Util.string2DateTime(timeEnd)
				return Util.isBetweenTimes(timeFromPath,timeStart,timeEnd)
			TYPE_ARRAY:
				logOut("Multiple Times for condition timeBetween currently not supported")
			var conType:
				logOut(["Unexpected type of condition.val ",conType," in ",condition],"ERROR")
				return false
	elif condition.mode[0] == "¬":
		var invertedCondition = condition.duplicate()
		invertedCondition.mode = condition.mode.substr(1,condition.mode.length()-1)
		return !checkCondition(invertedCondition)
	return false
	
func checkConditionString(condition:String) -> bool:
	
	if condition[0] == "¬" and condition[1] == "(" and condition[condition.length()-1] == ")":
		return !checkConditionString(condition.substr(2,condition.length()-3))
	
	
	var result
	
	var regex_whitespace = "\\s*"
	
	var regex_anything = ".+"
	var regex_logic = "AND|X?OR"
	
	var regex_string_logic = "{ws}\\(({anything})\\){ws}({logic}){ws}\\(({anything})\\){ws}"
	regex_string_logic = regex_string_logic.format({"anything":regex_anything,"logic":regex_logic,"ws":regex_whitespace})
	
	var regex_logical = Util.regex(regex_string_logic)
	result = regex_logical.search(condition)
	
	
	
	if result:
		# String has form "(anything) AND (anything)"
		var resultString = result.get_strings()
		var c1 = resultString[1]
		var c2 = resultString[3]
		
		var logic = resultString[2]
		
		match logic:
			"AND":
				if checkConditionString(c1):
					return checkConditionString(c2)
				return false
			"OR":
				if !checkConditionString(c1):
					return checkConditionString(c2)
				return true
			"XOR":
				if checkConditionString(c1):
					return !checkConditionString(c2)
				return checkConditionString(c2)
			_:
				logOut(["Unsupported logical operator in checkConditionString:",logic],"ERROR")
				return false
	
	var regex_identifier = "[a-zA-Z0-9'\\._\\-\\(\\)\\[\\],]+"
	var regex_operator = "[><=]{1,2}|!=|€|⊆"
	
	
	var regex_string_operator = "{ws}({identifier}){ws}({operator}){ws}({identifier}){ws}"
	regex_string_operator = regex_string_operator.format({"identifier":regex_identifier,"operator":regex_operator,"ws":regex_whitespace})
	
	var regex_compare = Util.regex(regex_string_operator)
	result = regex_compare.search(condition)
	
	if result:
		var resultString = result.get_strings()
		var id1 = resultString[1]
		var id2 = resultString[3]
		var val1 = getValueFromPath(id1,null)
		var operator = resultString[2]
		
		if operator == "€":
			var lowMode = id2[0]
			var highMode= id2[id2.length()-1]
			
			var setArr = id2.split(",")
			
			if setArr.size() != 2:
				logOut("Invalid set format in checkConditionString","ERROR")
				return false
			
			var lowVal = getValueFromPath(setArr[0].substr(1,setArr[0].length()-1))
			var highVal= getValueFromPath(setArr[1].substr(0,setArr[1].length()-1))
			
			if lowVal <= highVal:
				match lowMode:
					"(":
						if Util.bigger(lowVal,val1) or Util.equals(lowVal,val1): return false
					"[":
						if Util.bigger(lowVal,val1): return false
					_:
						logOut(["Unsupported lower bound in checkConditionString:",lowMode],"ERROR")
						return false
						
				match highMode:
					")":
						if Util.bigger(val1,highVal) or Util.equals(highVal,val1): return false
					"]":
						if Util.bigger(val1,highVal): return false
					_:
						logOut(["Unsupported lower bound in checkConditionString:",lowMode],"ERROR")
						return false
				return true
			else:
				#Example (10,5] means all values higher than 10 or lower or equal 5 are true
				match lowMode:
					"(":
						if Util.bigger(val1,lowVal): return true
					"[":
						if Util.bigger(val1,lowVal) or Util.equals(lowVal,val1): return true
					_:
						logOut(["Unsupported lower bound in checkConditionString:",lowMode],"ERROR")
						return false
						
				match highMode:
					")":
						if Util.bigger(highVal,val1): return true
					"]":
						if Util.bigger(highVal,val1) or Util.equals(highVal,val1): return true
					_:
						logOut(["Unsupported lower bound in checkConditionString:",lowMode],"ERROR")
						return false
			
				return false
			
		var val2 = getValueFromPath(id2,null)
		
		match operator:
			"=","==":
				return Util.equals(val1,val2)
			">":
				return Util.bigger(val1,val2)
			"<":
				return Util.bigger(val2,val1)
			">=":
				return (Util.bigger(val1,val2) or Util.equals(val1,val2))
			"<=":
				return (Util.bigger(val2,val1) or Util.equals(val1,val2))
			"!=","<>":
				return !Util.equals(val1,val2)
			"⊆":
				return Util.isInArray(val1,val2)
			_:
				logOut(["Unsupported operator in checkConditionString:",operator],"ERROR")
				return false
	
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
	# Load mods here
	for category in events:
		var catArray = events[category].values()
		catArray.sort_custom(SorterByPriorityInt,"sort")
		events[category] = catArray
	print("Complete loading Events")

func eventCategoryExecute(cat, times = 1):
	if !events.has(cat): 
		logOut(["Event category not found: ",cat],"ERROR")
		return
	
	for i in range(times):
		for event in events[cat]:
			execute(event.actions)
			if getValue(event,"consume",false) == true: return

func eventArgumentExecute(cat, arg, minutes):
	if !events.has(cat): return
	for event in events[cat]:
		if event.arguments == "*" or Util.isInStr(arg,event.arguments):
			var chanceToHappen = 1 # without mtth the event will happen no matter what
			if event.has("mtth"):
				chanceToHappen = 1-pow(1-(1/event.mtth),minutes)
			if chanceToHappen >= rng.randf():
				execute(event.actions)
				if getValue(event,"consume",false) == true: return

func loadFunctionFile(filePath):
	var file = File.new()
	file.open(filePath, file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		var ffunctions = temp.result
		for functionId in ffunctions:
			functions[functionId] = ffunctions[functionId]
	else:
		print("Error loading Functions :"+str(temp.error))

func loadFunctions(path="res://data"):
	var functionFiles = Util.getFilesInFolder(path+"/script/functions")
	for functionFile in functionFiles:
		loadFunctionFile(path+"/script/functions/"+functionFile)

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

func loadThemes():
	
	var boxes = [
		["Panel","panel"],
		["PanelContainer","panel"],
		["RichTextLabel","normal"]
	]
	
	var colors = [
		["Button","font_color"],
		["Label","font_color"],
		["RichTextLabel","default_color"]
	]
	
	var file = File.new()
	file.open("res://data/themes/themes.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error != OK: return
		
	var themesFromFile = temp.result
	for themeId in themesFromFile:
		var themeData = themesFromFile[themeId]

		if typeof(themeData) != TYPE_DICTIONARY or themeData.empty(): continue
		
		themes[themeId] = {}
		
		for subThemeId in themeData:
			
			var subThemeData = themeData[subThemeId]
			if typeof(subThemeData) != TYPE_DICTIONARY or subThemeData.empty(): continue

			var color_bg = null
			var color_font=null
			
			if subThemeData.has("color_bg"):
				color_bg = Color(subThemeData.color_bg)
			if subThemeData.has("color_font"):
				color_font=Color(subThemeData.color_font)
			
			
			var styleBoxFlat = StyleBoxFlat.new()
			styleBoxFlat.bg_color = color_bg
			
			
			
			var theme = Theme.new()
			
			for box in boxes:
				if color_bg != null: theme.set_stylebox(box[1],box[0],styleBoxFlat)
		
			for color in colors:
				if color_font != null: theme.set_color(color[1],color[0],color_font)
				
			themes[themeId][subThemeId] = theme
	

func locationInherit(l):
	l = linkObject(l)
	if l.has("inherit"):
		var lArr = l.inherit.split(".")
		if lArr[0] == "SELF":
			lArr[0] = l.SELF
			l.inherit = PoolStringArray(lArr).join(".")
		var parent = getLocation(l.inherit)
		l = Util.inherit(l,parent)
	return l

func logOut(msg,type="NOTICE"):
	
	if typeof(msg) == TYPE_ARRAY:
		var text = ""
		for t in msg:
			text += str(t)
		msg = text
	else:
		msg = str(msg)
	
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

func mainMenu():
	return get_tree().change_scene("res://scenes/titleScreen/titleScreen.tscn")

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
	loadThemes()

func detailsHide():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowDetailsPC = false
	
	functionParameters.pop_back()
	
	updateUI()

func detailsShow():
	MiscData.currentNpcId[3] = PlayerData.ID
	
	#modifiersCalculate(PlayerData.ID)
	#modifiersCalculate()
	
	CurrentUi.UIGroup = "uiDetails"
	CurrentUi.ShowDetailsPC = true
	
	CurrentUi.ActiveModfiers.clear()
	
	for modifierGroupId in PlayerData.modifier:
		CurrentUi.ActiveModfiers[modifierGroupId] = []
		var modifierGroup = PlayerData.modifier[modifierGroupId]
		for modifierId in modifierGroup:
			var modifier = getModifier(modifierGroupId,modifierId)
			#modifier.description = parseText(modifier.description)
			CurrentUi.ActiveModfiers[modifierGroupId].append(modifier)
	
	functionParameters.append([PlayerData])
		
	updateUI()
	
func UIGroupStackPop():
	CurrentUi.UIGroupStack
	CurrentUi.UIGroup = CurrentUi.UIGroupStack.pop_back()
	
func getModifier(modifierGroupId,modifierID):
	return modifiers[modifierGroupId][modifierID]

func getMonthData(id):
	if !misc.has("month"): loadMisc()
	if misc.month.has(id):
		var month = misc.month[id]
		if month.has("inherit"):
			var parent = getMonthData(month.inherit)
			month = Util.inherit(month,parent)
		return month
	return {}

func modifiersCalculate():
	
	functionParameters.append([PlayerData])
	#var npc = getNPC(npcId)
	
	if !PlayerData.has("modifier"): PlayerData.modifier = {}
	PlayerData.modifier.clear()
	if !PlayerData.has("property"): PlayerData.property = {}
	PlayerData.property.clear()
	
	CurrentUi.StatusMods = []
	
	#MiscData.currentNpcId[3] = npcId
	
	for modifierGroupId in modifiers:
		var modifierGroup = modifiers[modifierGroupId]
		PlayerData.modifier[modifierGroupId] = []
		var modSum = 0
		var modMult= 1
		for modifierId in modifierGroup:
			var modifier = modifierGroup[modifierId]
			if checkCondition(modifier.condition):
				PlayerData.modifier[modifierGroupId].append(modifierId)
				var add = getValue(modifier,"modifier",0)
				var mult = getValue(modifier,"modifierMult",1)
				modSum += add
				modMult*= mult
				if getValue(modifier,"statBar",false) == true: CurrentUi.StatusMods.append(modifier)
				
		PlayerData.property[modifierGroupId] = modSum*modMult
		
	MiscData.modifiersRecalc = false
	
	functionParameters.pop_back()

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
	#modifiersCalculate(PlayerData.ID)
	modifiersCalculate()

	gotoMain()
	
func execute(commands):
	var results = executeCommands(commands)
	#if results.get("modifiersRecalc",false) == true: MiscData.modifiersRecalc = true #modifiersCalculate(PlayerData.ID)
	return results.get("consume",false)
	
func executeCommands(commands):
	
	# low level, don't call directly
	
	#var consume = false
	var result = {}
	
	if typeof(commands) == TYPE_ARRAY:
		
		for command in commands:
			#if execute(command): consume = true
			result = Util.mergeDictBoolOr(execute(command),result)
		return result #consume
	
	if commands.get("Disabled",false) == true: return result
	
	
				
	
	if commands.has("foreach"):
		var subcommand = commands.foreach.duplicate()
		subcommand.erase("iterate")
		var target = getValueFromPath(commands.foreach.iterate)
		match typeof(target):
			TYPE_DICTIONARY:
				for key in target:
					var entry = target[key]
					#functionObjects.append(entry)
					functionParameters.append([entry])
					executeCommands(subcommand)
					functionParameters.pop_back()
					#functionObjects.pop_back()
		return result
					
	
	if commands.has("debug"):
		logOut(["DEBUG: ",commands.debug])
	
	if commands.has("bg"):
		CurrentUi.Bg = commands["bg"]
		
	match getValue(commands,"text",null):
		null:
			CurrentUi.Text  = ""
		var text:
			if typeof(text) == TYPE_ARRAY: text = PoolStringArray(text).join("\n")
			CurrentUi.Text = parseText(text)
			
	match getValue(commands,"textLong",null):
		null:
			CurrentUi.erase("TextLong")
		var textLong:
			if typeof(textLong) == TYPE_ARRAY: textLong = PoolStringArray(textLong).join("\n")
			CurrentUi.TextLong = parseText(textLong)
		
	for dataContainer in ["PlayerData","MiscData","PARAM1","WorldData","TEMP","CurrentUi"]:
		result.modifiersRecalc = true
		if commands.has(dataContainer):
			var command = commands[dataContainer]
			for key in command:
				if typeof(command[key]) == TYPE_DICTIONARY:
					if command[key].has("mode"):
						modValueAtPath(dataContainer+"."+key,command[key].mode,getValue(command[key],"value",0))
					else:
						modValueAtPath(dataContainer+"."+key,"set",getValue(command[key],"value",0))
				else:
					setValueAtPath(dataContainer+"."+key,command[key])
			
	if commands.has("eat"):
		var saturation = getValue(commands.eat,"saturation",0)
		stateInc("hunger",saturation)
		#result.modifiersRecalc = true
	if commands.has("drink"):
		var saturation = getValue(commands.drink,"saturation",0)
		stateInc("thirst",saturation)
		#result.modifiersRecalc = true
	if commands.has("sleep"):
		sleep(getValue(commands.sleep,"mode",""))
		#result.modifiersRecalc = true
		
		
	if commands.has("playerOutfit"):
		setPlayerOutfit(commands.playerOutfit)
		#result.modifiersRecalc = true
		
	if commands.has("NPCData"):
		for key in commands.NPCData:
			for entry in commands.NPCData[key]:
				setValueAtPath("NPC"+key+".persist."+entry,commands.NPCData[key][entry])
	
	
	var time = getValue(commands,"Time")
	if time:
		var timeOffset = getValue(time,"Offset")
		if timeOffset:
			WorldData.TimeOffset = int(timeOffset)
			timeUpdate()
		
		var timePass = getValue(time,"Pass")
		if timePass:
			var Activity = getValue(timePass,"Activity","idle")
			var Duration = getValue(timePass,"Duration",0)
			
			var SetTime = getValue(timePass,"SetTime",0)
			if SetTime:
				Duration = Util.getSecondsTil(now(),SetTime,true)
			
			timePass(Duration,Activity)
			#result.modifiersRecalc = true
	
	# Comes here so that conditionals can override non-conditionals but do not get canceld by consuming events
	if commands.has("conditionExecute"):
		var cEs = commands.conditionExecute
		for cEID in cEs:
			var cE = cEs[cEID]
			if !cE.has("condition") or checkCondition(cE.condition):
				if execute(cE): 
					result.consume = true
					return result
	
		
	#if commands.has("goto"):
	var goto = getValue(commands,"goto",null)
	match typeof(goto):
		TYPE_STRING:
			var gotoArr = goto.split(".")
			if gotoArr[0] == "SELF":
				gotoArr[0] = MiscData.currentLocationID.split(".")[0]
				goto = PoolStringArray(gotoArr).join(".")
			MiscData.currentLocationID = goto
			var gotoLocation = getLocation(goto)
			executeLocation(gotoLocation)#
			result.consume = true
			return result
		TYPE_DICTIONARY:
			var location = locationInherit(goto)
			executeLocation(location,false,false)
			result.consume = true
			return result
		
	
	if commands.has("gotoLocationPop"):
		var locationId = MiscData.locationStack.pop_back()
		return executeCommands({"goto":locationId})
		
	if commands.has("interrupt"):
		MiscData.locationStack.append(MiscData.currentLocationID)
		return executeCommands({"goto":commands.interrupt})
		
	if commands.has("dialogue"):
		var dialogue = getValue(commands,"dialogue",{})
		#var dialogueId = getValue(dialogue,"id","")
		var npcId = getValue(dialogue,"npc","")
		
	if commands.has("gotoShop"):
		shop(commands.gotoShop)
		result.consume = true
		return result
		
	if commands.has("services"):
		services(commands.services)
		result.consume = true
		return result
		
	if commands.has("showWardrobe"):
		wardrobe()
		result.consume = true
		return result
	
	if commands.has("showDialog"):
		var dialogId = commands.showDialog
		var dialogParam = {}
		if typeof(dialogId) == TYPE_DICTIONARY:
			dialogParam = dialogId
			dialogId = dialogId.dialog
		var dialog = load("res://scenes/dialog/"+dialogId+".tscn").instance()
		if dialog.has_method("setParam"): dialog.setParam(dialogParam)
		get_tree().get_root().add_child(dialog)
		dialog.popup_centered()
		
		CurrentUi.UIGroupStack.append(CurrentUi.UIGroup)
		CurrentUi.UIGroup = "uiDialog"
	
	if getValue(commands,"updateLocation",false) == true:
		updateLocation()
	
	return result
	
func parseText(t:String)->String:
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
				textReturn += str(getValueFromPath(textArr[i]))
		i += 1
	return textReturn

func path(p):
	if p.substr(0,7) == "mods://":
		return getModFolder() + "/" + p.substr(7,p.length()-7)
	return p

func currentUIAppendRL(rl):
	if !rl.has("condition") or checkCondition(rl.condition):
		rl = reachableLocationLink(rl)
		if rl.has("inherit"):
			var parent = getRL(rl.inherit)
			rl = Util.inherit(rl, parent)
		if hasValue(rl,"values"):
			var targetLocation = getLocation(getValue(rl,"locationId"))
			functionParameters.append([rl,targetLocation])
			var values = getValue(rl,"values",{})
			rl = Util.inherit(rl, values)
			functionParameters.pop_back()
		CurrentUi.RL.append(rl)

func executeLocation(location,omitStart=false,updateLocationId=true):
	#functionObjects.append(location)
	executeLocationCommands(location,omitStart,updateLocationId)
	#functionObjects.pop_back()
		
func executeLocationCommands(location,omitStart=false,updateLocationId=true):
	var onStart = getValue(location,"onStart")
	if !omitStart and onStart:
		if execute(onStart): return
	
	var bgTemp = getValue(location,"bg")
	#if bgTemp != null:
	CurrentUi.Bg  = bgTemp
	
	match getValue(location,"text",null):
		null:
			CurrentUi.Text  = ""
		var text:
			if typeof(text) == TYPE_ARRAY: text = PoolStringArray(text).join("\n")
			CurrentUi.Text = parseText(text)
			
	match getValue(location,"textLong",null):
		null:
			CurrentUi.erase("TextLong")
		var textLong:
			if typeof(textLong) == TYPE_ARRAY: textLong = PoolStringArray(textLong).join("\n")
			CurrentUi.TextLong = parseText(textLong)
		
	CurrentUi.RL.clear()
	var rls = getValue(location,"rl",null)
	if rls:
		CurrentUi.ShowRL = true
		match typeof(rls):
			TYPE_ARRAY:
				for rl in rls:
					currentUIAppendRL(rl)
			TYPE_DICTIONARY:
				for rlId in rls:
					currentUIAppendRL(rls[rlId])
			var rlType:
				logOut(["Unexpected type of location.rl: ",rlType],"ERROR")
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
	if hasValue(location,"actions"):
		var actions = getValue(location,"actions")
		var keys = actions.keys()
		keys.sort_custom(SorterByIndexInt, "sortInv")
		for key in keys:
			var action = actions[key].duplicate()
			action = linkAction(action)
			
			if action.has("goto"):
				var actionGotoArr = action.goto.split(".")
				if actionGotoArr[0] == "SELF":
					actionGotoArr[0] = location.SELF
					action.goto = actionGotoArr.join(".")
					
				var targetLocation = getLocation(action.goto)
				
			if "condition" in action:
				if checkCondition(action["condition"]) == true:
					CurrentUi.Actions.append(action)
			else:
				CurrentUi.Actions.append(action)

	if updateLocationId:
		CurrentUi.LocationId = location.ID
	updateUI()

func executeWithParameter(commands,parameter):
	match typeof(parameter):
		TYPE_ARRAY:
			functionParameters.append(parameter)
		_:
			functionParameters.append([parameter])
	#functionObjects.append(fobj)
	execute(commands)
	#functionObjects.pop_back()
	functionParameters.pop_back()

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
	CurrentUi.ShowGameStatus = !CurrentUi.get("ShowGameStatus",false)
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

func npcDetailsHide():
	CurrentUi.ShowDetailsNPC = false
	CurrentUi.UIGroup = "uiUpdate"
	updateUI()

func npcDetailsShow(npc):
	CurrentUi.ShowDetailsNPC = true
	CurrentUi.UIGroup = "uiNpcDetails"
	get_tree().call_group(CurrentUi.UIGroup,"setNPC",npc)
	updateUI()

func npcDialogHide():
	functionParameters.pop_back()
	CurrentUi.ShowNPCDialog = false
	CurrentUi.UIGroup = "uiUpdate"
	updateUI()	

func npcDialogShow(npc):
	CurrentUi.NPCDialog = []
	functionParameters.append([npc])
	
	CurrentUi.ShowNPCDialog = true
	CurrentUi.UIGroup = "uiNpcDialog"
	
	var greetingUsed = {"priority":-1,"topic":"TOP","dialogueId":""}
	
	var npcDialogues = getValue(npc,"dialogue",[])
	for npcDialogue in npcDialogues:
		var dialogue:Dictionary = getDialogue(npcDialogue)
		var greetings = getValue(dialogue,"greetings",{})
		for greetingId in greetings:
			var greeting = greetings[greetingId]
			if getValue(greeting,"priority",0) > greetingUsed.priority and (!greeting.has("condition") or checkCondition(greeting.condition)):
				greetingUsed = greeting
				greetingUsed.dialogueId = npcDialogue
				
	var greetingTopicId = getValue(greetingUsed,"topic")
	if greetingTopicId:
		npcDialogTopic(greetingTopicId,greetingUsed.dialogueId)
				
	updateUI()

func npcDialogReply(reply:Dictionary):
	var dialogueId = getValue(reply,"dialogue","")
	var msg = getValue(reply,"text","")
	var onSelect = getValue(reply,"onSelect",{})
	var afterSelect = getValue(reply,"afterSelect",{})
	var topic = getValue(reply,"topic",null)
	var goto = getValue(reply,"goto",null)
	
	if msg != "": npcDialogSay(PlayerData.ID,msg)
	
	execute(onSelect)
	
	if topic:
		npcDialogTopic(topic,dialogueId)
	elif goto:
		npcDialogHide()
		execute({"goto":goto})
	else:
		npcDialogTopic("TOP",dialogueId)
	
	execute(afterSelect)

func npcDialogSay(charId:String,text:String):
	var statement = {"charId":charId,"text":text}
	CurrentUi.NPCDialog.append(statement)
	updateUI()

func npcDialogSetReplies(replies,dialogueId):
	match typeof(replies):
		TYPE_DICTIONARY:
			CurrentUi.NPCDialogOption = replies.values()
		TYPE_ARRAY:
			CurrentUi.NPCDialogOption = replies
	for npcDO in CurrentUi.NPCDialogOption:
		npcDO.dialogue = dialogueId

func npcDialogTopTopics(npc:Dictionary)->Array:
	var result = []
	var npcDialogues = getValue(npc,"dialogue",[])
	for npcDialogue in npcDialogues:
		var dialogue:Dictionary = getDialogue(npcDialogue)
		var topics = getValue(dialogue,"topics",{})
		for topicId in topics:
			var topic = topics[topicId]
			topic.dialogueId = npcDialogue
			topic.ID = topicId
			if getValue(topic,"TOP"):
				result.append(topic)
	return result

func npcDialogTopic(topicId:String,dialogueId:String="",subtopic:int=1):
	if topicId == "LEAVE":
		npcDialogHide()
		return
		
	if topicId == "TOP":
		var topTopics = npcDialogTopTopics(functionParameters.back()[0])
		var topTopicOptions = []
		for topTopic in topTopics:
			var reply = {"topic":topTopic.dialogueId+"."+topTopic.ID,"label":getValue(topTopic,"TOP",topTopic.ID),"text":getValue(topTopic,"TOP_text","")}
			topTopicOptions.append(reply)
		topTopicOptions.append({"topic":"LEAVE","label":"Leave"})
		npcDialogSetReplies(topTopicOptions,dialogueId)
		updateUI()
		return
			
	var topicArr = topicId.split(".")
	
	match topicArr.size():
		2:
			if topicArr[0] != "SELF":
				dialogueId = topicArr[0]
			topicId = topicArr[1]
		3: 
			if topicArr[0] != "SELF":
				dialogueId = topicArr[0]
			topicId = topicArr[1]
			subtopic = int(topicArr[2])

	var dialogue = getDialogue(dialogueId)
	var topics = getValue(dialogue,"topics",{})
	var topic = getValue(topics,topicId,{})
	var subTopic = getValue(topic,str(subtopic),{})
	var text = getValue(subTopic,"text","")
	var replies = getValue(subTopic,"replies",[])
	var onShow = getValue(subTopic,"onShow",null)
	
	match typeof(text):
		TYPE_STRING:
			npcDialogSay(functionParameters.back()[0].ID,text)
		TYPE_DICTIONARY:
			var keys = text.keys()
			keys.sort_custom(SorterByIndexInt, "sort")
			for key in keys:
				var subtext = text[key]
				match typeof(subtext):
					TYPE_DICTIONARY:
						var speakerId = getValue(subtext,"speakerId","NARRATOR")
						var line = getValue(subtext,"text","Line missing")
						npcDialogSay(speakerId,line)
			
	if onShow:
		execute(onShow)
			
	if replies.empty():
		var nextTopic=getValue(subTopic,"topic","")
		if nextTopic:npcDialogTopic(nextTopic,dialogueId)
	else:
		npcDialogSetReplies(replies,dialogueId)
		updateUI()


func getEvent(cat,id):
	if !events.has(cat) or !events[cat].has(id):
		logOut(["Event ",id," not found in ",cat],"ERROR")
		return {}
	return events[cat][id]
	
func getFunction(id):
	if !functions.has(id):
		logOut(["Function ",id," not found"],"ERROR")
		return {}
	return functions[id]

	

	


func gotoLocation(transferInfo):
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
	
func timePass(t:int,activity):
	if t <= 0: return
	
	var targetTime:int = t+now()
	
	eventArgumentExecute("timePass",activity,t/60)
	
	if activity == "sleep":
		for stat in PlayerData.stat:
			var changePerSecond = -getValue(PlayerData.stat[stat],"decaySleep",0)
			stateInc(stat,changePerSecond * t)
	else:
		for stat in PlayerData.stat:
			var changePerSecond = -getValue(PlayerData.stat[stat],"decay",0)
			stateInc(stat,changePerSecond * t)
	
	var hoursToCalc = Util.getHoursTilTime(now(),targetTime)
	var daysToCalc = Util.getDaysTilDate(now(),targetTime,false)
	
	#quick and dirty calc modifiers every 10 minutes
	if int(targetTime/600) > int(now()/600):modifiersCalculate()
	
	if hoursToCalc > 0:
		eventCategoryExecute("timePass_HOUR",hoursToCalc)
		#modifiersCalculate()
		weatherUpdate(targetTime)
	
	if daysToCalc > 0:
		eventCategoryExecute("timePass_DAY",daysToCalc)
	
	MiscData.modifiersRecalc = true
	timeMove(t)
	updateLocation()
	
		
func timeMove(t):
	#meant for internal use, most modules might want to call timePass()
	t = int(t)
	WorldData.Time += t
	#CurrentUi.Time = now()
	timeUpdate()
	#playerData2UI()

func timeUpdate():
	WorldData.TimeDict = Util.getDateTime(now())

#var preloadedTextures = []
#var preloadedTexturesMax = 20
#func preloadTexture(path):
#	if path == null: return
#	if typeof(path) == TYPE_ARRAY: path = path[0]
#	preloadedTextures.append(load(path))
#	if preloadedTextures.size() > preloadedTexturesMax:
#		preloadedTextures.pop_front()

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

func reload():
	logOut("Reload")
	locations.clear()
	var location = getLocation(CurrentUi.LocationId)
	executeLocation(location,true,false)

func updateLocation():
	var location = getLocation(CurrentUi.LocationId)
	executeLocation(location,true,false)


var uiUpdatePending:bool = false
func updateUI():
	uiUpdatePending=true

func _process(delta):
	if uiUpdatePending:
		playerData2UI()
		get_tree().call_group(CurrentUi.UIGroup,"updateUI",CurrentUi)
		if CurrentUi.UIGroup!= "uiUpdate":
			get_tree().call_group("uiUpdate","updateUI",CurrentUi)
		uiUpdatePending=false

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
			
	MiscData.modifiersRecalc = true	
	
func setItemWorn(item):
	#PlayerData.outfit.CURRENT[item.type] = item.ID
	#eventCategoryExecute("outfitUpdate")
	#playerData2UI()
	#updateUI()
	setItemWornAtSlot(item.type,item.ID)

func setItemWornAtSlot(slot,itemID):
	PlayerData.outfit.CURRENT[slot] = itemID
	eventCategoryExecute("outfitUpdate")
	playerData2UI()
	updateUI()

func serviceBuy(serviceId):
	var service = getServiceById(serviceId)
	var duration = 0
	var activity = "idle"
	if service.has("time"): duration = service.time
	if duration > 0 : timePass(duration,activity)
	if service.has("price"): moneySpend(service.price)
	if service.has("effects"): 
		executeWithParameter(service.effects,service)
	
	if service.has("availableCountRef"):
		var decrease = getValue(service,"availableCountDec",1)
		var current = getValueFromPath(service.availableCountRef,0)
		var target = current - decrease
		setValueAtPath(service.availableCountRef,target)
		
	if service.has("increaseRef"):
		var increase = getValue(service,"increaseCount",1)
		var current = getValueFromPath(service.increaseRef,0)
		var target = current + increase
		setValueAtPath(service.increaseRef,target)
	
	modifiersCalculate()
	
	if getValue(service,"remainAtServices",false) == false:
		servicesClose()
	else:
		servicesUpdate()

func services(type,category=""):
	CurrentUi.UIGroup = "uiServices"
	CurrentUi.ShowServices = true
	CurrentUi.Services.type = type
	CurrentUi.Services.category = category
	
	CurrentUi.Services.available.clear()
	CurrentUi.Services.availableCategories.clear()
	
	for serviceId in services:
		var service = getServiceById(serviceId)
		if getValue(service,"isTemplate",false) == true: continue
		#logOut(service)
		if type in getValue(service,"available",[]):
			CurrentUi.Services.available.append(serviceId)
			var serviceCategory = getValue(service,"category","Category Missing")
			if !CurrentUi.Services.availableCategories.has(serviceCategory):
				CurrentUi.Services.availableCategories[serviceCategory] = {"ID":serviceCategory,"label":serviceCategory,"texture":service.texture}
	updateUI()

func servicesClose():
	CurrentUi.UIGroup = "uiUpdate"
	CurrentUi.ShowServices = false
	#CurrentUi.Wardrobe.selitems.clear()
	updateUI()

func servicesUpdate():
	services(CurrentUi.Services.type,CurrentUi.Services.category)
	
func stateInc(index:String,value:int):
	stateSet(index, PlayerData.stat[index].current + value)
	
func stateSet(index:String,value:int):
	value = min(max(value,0),10000)
	PlayerData.stat[index].current = value
	MiscData.modifiersRecalc = true



func undress(slot:String):
	setItemWornAtSlot(slot,"")

func weatherForecast(targetTimeDict:Dictionary,allowMeta = true):
	var forecastIndex = weatherForecastIndex(targetTimeDict)
	var forecast = getValueFromPath("WorldData.weather.forecast."+forecastIndex,null)
	if typeof(forecast) == TYPE_NIL:
		forecast = weatherForecastGenerate(targetTimeDict,allowMeta)
	return forecast

func weatherForecastGenerate(targetTimeDict:Dictionary,allowMeta = true):
	var forecast = "mild"
	
	var forecastIndex = weatherForecastIndex(targetTimeDict)
	var forecastKeysFIFO = getValueFromPath("WorldData.weather.forecast.KeysFIFO",[])
	
	var monthId = str(targetTimeDict.month)
	
	var monthData = getMonthData(monthId)
	
	
	### Random Pick
	var weightTotal = 0
	
	var metaCommands = ["repeat"]
	
	for weatherId in monthData.weather:
		if !allowMeta and weatherId in metaCommands: continue
		var weight = monthData.weather[weatherId]
		weightTotal += weight
		
	var rand = rng.randi_range(1,weightTotal)
	
	for weatherId in monthData.weather:
		if !allowMeta and weatherId in metaCommands: continue
		var weight = monthData.weather[weatherId]
		if weight >= rand:
			forecast = weatherId
			break
		rand -= weight
	### Random Pick End
	
	
	forecastKeysFIFO.append(forecastIndex)
	setValueAtPath("WorldData.weather.forecast."+forecastIndex,forecast)
	
	var forecastSize = max(getValue(Preferences,"weatherForecastSize",5),1)
	while(forecastKeysFIFO.size() > forecastSize):
		WorldData.weather.forecast.erase(forecastKeysFIFO.pop_front())
	
	setValueAtPath("WorldData.weather.forecast.KeysFIFO",forecastKeysFIFO)
	
	return forecast

func weatherForecastGenerateForNextDays(targetTime,currentForecast:String):
	var targetTimeInt = Util.getUnixTime(targetTime)
	var forecastSize = max(getValue(Preferences,"weatherForecastSize",5),1)
	for i in range(forecastSize-1):
		var targetTimeNext = targetTimeInt + (i+1) * 86400
		var targetTimeNextDict = Util.getDateTime(targetTimeNext)
		#var forecastNextIndex = weatherForecastIndex(targetTimeNextDict)
		#var forecast = getValueFromPath("WorldData.weather.forecast."+forecastNextIndex,null)
		#if typeof(forecast) == TYPE_NIL:
		#	weatherForecastGenerate(targetTimeNextDict)
		var forecast = weatherForecast(targetTimeNextDict)
		if forecast == "repeat":
			forecast = currentForecast
			weatherForecastSet(targetTimeNextDict,forecast)
		else:
			currentForecast = forecast
		

func weatherForecastIndex(targetTimeDict:Dictionary):
	return str(targetTimeDict.month * 100 + targetTimeDict.day)
	
func weatherForecastSet(targetTimeDict:Dictionary,forecast):
	var forecastIndex = weatherForecastIndex(targetTimeDict)
	setValueAtPath("WorldData.weather.forecast."+forecastIndex,forecast)
	
func weatherSky(weather:Dictionary) -> String:
	
	var possibleSkies = getValue(weather,"sky",{})
	
	var weightTotal = 0
	
	for sky in possibleSkies:
		var weight = possibleSkies[sky]
		weightTotal += weight
		
	var rand = rng.randi_range(1,weightTotal)
	
	for sky in possibleSkies:
		var weight = possibleSkies[sky]
		if weight >= rand:
			return sky
		rand -= weight
	
	return "rain"

func weatherUpdate(targetTime):
	var targetTimeDict = Util.getDateTime(targetTime)
		
	var forecastIndex = weatherForecastIndex(targetTimeDict)

	var weatherId:String = weatherForecast(targetTimeDict,false)
	weatherForecastGenerateForNextDays(targetTime,weatherId)
	
	var weather:Dictionary = getWeather(weatherId)
	
	var monthData = getMonthData(str(targetTimeDict.month))
	
	var timeOfDay:String = getValue(monthData,"sun."+str(targetTimeDict.hour),"night")
	
	var temperature:int
	
	if hasValue(weather,"temperature."+timeOfDay):
		temperature = Util.intRandom(getValue(weather,"temperature."+timeOfDay,0))
	else:
		var topTimeOfDay = timeOfDay.substr(0,timeOfDay.length()-1)
		temperature = Util.intRandom(getValue(weather,"temperature."+topTimeOfDay,0))
			
	var sky = weatherSky(weather)
	
	WorldData.weather.sky = sky
	WorldData.weather.temperature = temperature
	WorldData.weather.timeOfDay = timeOfDay