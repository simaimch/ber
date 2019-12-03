extends Control

var rng = RandomNumberGenerator.new()

var cache_regex
var cache_texture

func _ready():
	cache_texture = Cache.new(funcref(self,"textureLoad"),200)
	cache_regex = Cache.new(funcref(self,"regexLoad"),20)
	

func folderFromPath(path:String)->String:
	var pathArr = path.split("/")
	var fileName = pathArr[pathArr.size()-1]
	var fileNameParts = fileName.split(".")
	if fileNameParts.size() == 1: return path #path already was a folder
	return path.substr(0,path.length()-fileName.length()-1)

func formatDuration(d)->String:
	if d >= 7200:
		return str(int(d/3600))+" hours"
	elif d >= 120:
		return str(int(d/60))+" minutes"
	else:
		return str(d)+" seconds"

func formatInt(i,format="00")->String:
	var result = ""
	if format == "00":
		if i < 10 and i >= 0:
			result = "0"+str(i)
		else:
			result = str(i)
	return result
	
func formatMoney(money)->String:
	money = int(money)
	var text = str(money/100) + ","+formatInt(money%100,"00")+" €"
	return text
		
func formtTime(time,timeFormat="{day}.{month}.{year} {hour}:{minute}")->String:
	var dateTime = OS.get_datetime_from_unix_time (time)
	var day = formatInt(dateTime.day,"00")
	var month = formatInt(dateTime.month,"00")
	var year = formatInt(dateTime.year,"00")
	
	var hour = formatInt(dateTime.hour,"00")
	var minute = formatInt(dateTime.minute,"00")
	var second = formatInt(dateTime.second,"00")
	
	var weekday = ""
	match dateTime.weekday:
		0: weekday = "Sunday"
		1: weekday = "Monday"
		2: weekday = "Tuesday"
		3: weekday = "Wednesday"
		4: weekday = "Thursday"
		5: weekday = "Friday"
		6: weekday = "Saturday"
	
	return timeFormat.format({"day": day,"month": month,"year": year,"hour": hour,"minute": minute,"second":second,"weekday":weekday})

func formatTimeHHMMSS(t)->String:
	t = int(t)
	var seconds = t % 60
	var minutes = (t % 3600)/60
	var hours = t/3600
	
	var result = ""
	if hours > 0:
		result = formatInt(hours,"00")+":"
	result += formatInt(minutes,"00")+":"+formatInt(seconds,"00")
	return result

func formatVersion(v)->String:
	if typeof(v) != TYPE_INT: v = int(v)
	var v1 = v/10000
	var v2 = (v%10000)/100
	var v3 = v%100
	var result = str(v1)+"."+str(v2)+"."+str(v3)
	return result

func getFilename(path)->String:
	var pathArr = path.split("/")
	return pathArr[pathArr.size()-1]

func getFilesInFolder(path)->Array:
	#https://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true,true)
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files
	
func getFoldersInFolder(path)->Array:
	var folders = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true,true)
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif dir.current_is_dir() and !file.begins_with("."):
			folders.append(file)
	
	dir.list_dir_end()
	
	return folders

func getEmptyDateTime()->Dictionary:
	return {"year":1970,"month":1,"day":1,"hour":0,"minute":0,"second":0}

func string2DateTime(s)->Dictionary:
	#DD.MM.YYYY
	#hh:mm:ss or hh:mm
	#combine date and time with a single space in between, example:DD.MM.YYYY hh:mm:ss
	var result = getEmptyDateTime()
	var dateAndTime = s.split(" ")
	
	if dateAndTime.size() == 1:
		var date = dateAndTime[0].split(".")
		if date.size() == 1:
			var time = dateAndTime[0].split(":")
			result.hour = int(time[0])
			result.minute = int(time[1])
			if time.size() == 3:
				result.second = int(time[2])
		else:
			result.day = int(date[0])
			result.month = int(date[1])
			result.year = int(date[2])
	else:
		var date = dateAndTime[0].split(".")
		var time = dateAndTime[1].split(":")
		result.day = int(date[0])
		result.month = int(date[1])
		result.year = int(date[2])
		result.hour = int(time[0])
		result.minute = int(time[1])
		if time.size() == 3:
			result.second = int(time[2])
	return result
	
func getAge(now, bday)->int:
	var nowDict = getDateTime(now)
	var bdayDict= getDateTime(bday)
	
	if (nowDict.month > bdayDict.month) or (nowDict.month == bdayDict.month and nowDict.day >= bdayDict.day):
		return nowDict.year - bdayDict.year
	else:
		return nowDict.year - bdayDict.year - 1
		
func getDaysTilDate(now,target,anyyear = true)->int:
	var nowDict = datetimeResetTime(getDateTime(now))
	var targetDict= datetimeResetTime(getDateTime(target))
	
	if anyyear:
		if (nowDict.month > targetDict.month) or (nowDict.month == targetDict.month and nowDict.day > targetDict.day):
			targetDict.year = nowDict.year + 1
		else:
			targetDict.year = nowDict.year
			
	var secondsTilDate = getUnixTime(targetDict) - getUnixTime(nowDict)
	var daysTilDate = int(secondsTilDate/86400)
	return daysTilDate
	
func getHoursTilTime(now,target)->int:
	var nowDict = getDateTime(now)
	var targetDict= getDateTime(target)
	
	return int(targetDict.hour - nowDict.hour + 24*getDaysTilDate(now,target,false))

func getSecondsTil(now,target,sameDay = false)->int:
	var unixNow = getUnixTime(now)
	var unixTarget = getUnixTime(target)
	
	if sameDay:
		unixNow = unixNow % 86400
		unixTarget = unixTarget % 86400
	
	return (unixTarget - unixNow)

func getSecondsTilMidnight(t) -> int:
	var tdict = getDateTime(t)
	return (t.get("hour",0) * 3600 + t.get("minute",0) * 60 + t.get("second",0))

func getDateTime(dt) -> Dictionary:
	if typeof(dt) == TYPE_DICTIONARY: return mergeDateTime(getEmptyDateTime(),dt)
	if typeof(dt) == TYPE_STRING: return string2DateTime(dt)
	if typeof(dt) == TYPE_INT: return OS.get_datetime_from_unix_time(dt)
	if typeof(dt) == TYPE_REAL: return OS.get_datetime_from_unix_time(int(dt))
	print("Unexpected Parameter of Type "+str(typeof(dt))+" in Util.getDateTime():"+str(dt))
	return OS.get_datetime_from_unix_time(0)
	
func getUnixTime(time)->int:
	if typeof(time) == TYPE_DICTIONARY: return OS.get_unix_time_from_datetime(time)
	if typeof(time) == TYPE_STRING: return OS.get_unix_time_from_datetime(string2DateTime(time))
	if typeof(time) == TYPE_INT: return time
	if typeof(time) == TYPE_REAL: return int(time)
	#return "Unexpected Parameter of Type "+str(typeof(time))+" in Util.getUnixTime()"
	return 0

func loadJSONfromFile(path:String)->Dictionary:
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		return temp.result
	else:
		printerr("Error loading JSON from "+path+": "+str(temp.error))
		return {}

func clearChildren(obj):
	for i in obj.get_children():
    	i.queue_free()

func data2File(data,file:String,readable=false):
	var saveFile = File.new()
	saveFile.open(file, File.WRITE)
	if readable:
		saveFile.store_line(JSON.print(data,"	",true))
	else:
		saveFile.store_line(to_json(data))
	saveFile.close()

func datetimeResetTime(dt):
	if typeof(dt) == TYPE_DICTIONARY:
		dt.hour = 0
		dt.minute=0
		dt.second=0
		return dt
	if typeof(dt) == TYPE_INT:
		var dict = getDateTime(dt)
		dict.hour = 0
		dict.minute=0
		dict.second=0
		return getUnixTime(dict)



var debugLvl = 0
func debug(msg,level):
	if level <= debugLvl: print(msg)
	
func setDebugLevel(lvl):
	debugLvl = lvl

func arraySetAtIndex(array,index,value):
	var entriesToAdd = index - array.size() +1
	if entriesToAdd > 0:
		for i in range(entriesToAdd):
			array.append(null)
	array[index]= value
	return array
	
func bigger(a,b):
	var ta = typeof(a)
	var tb = typeof(b)
	
	if ta == TYPE_NIL: a = 0	
	elif ta == TYPE_STRING: a = int(a)
	elif ta != TYPE_INT and ta != TYPE_REAL: return false
	
	if tb == TYPE_NIL: b = 0	
	elif tb == TYPE_STRING: b = int(b)
	elif tb != TYPE_INT and tb != TYPE_REAL: return false
	
	return (a > b)
	

func equals(a,b):
	var ta = typeof(a)
	var tb = typeof(b)
	
	if (ta == TYPE_REAL or ta == TYPE_INT) and (tb == TYPE_REAL or tb == TYPE_INT):
		if a == b: return true
	
	if ta == TYPE_BOOL and tb != TYPE_BOOL:
		#b = bool(b)
		match tb:
			TYPE_NIL:
				return !a
			_:
				return false
				
	if tb == TYPE_BOOL and ta != TYPE_BOOL:
		#b = bool(b)
		match ta:
			TYPE_NIL:
				return !b
			_:
				return false
		
	#if tb == TYPE_BOOL and ta != TYPE_BOOL:
	#	a = bool(a)
	
	if ta == TYPE_NIL:
		if tb == TYPE_NIL or b == 0: return true
	if tb == TYPE_NIL and a == 0: return true
	
	if ta == TYPE_STRING or tb == TYPE_STRING:
		if str(a) == str(b): return true
		return false
	
	if a == b:
		return true
		
	return false
	
	
func fileExists(path):
	var file2Check = File.new()
	return file2Check.file_exists(path)
	
func folderCreate(parent, name):
	var dir = Directory.new()
	dir.open(parent)
	dir.make_dir_recursive(name)

func folderExists(path):
	var directory = Directory.new();
	return directory.dir_exists(path)

func isArray(a):
	match typeof(a):
		TYPE_ARRAY: return true
		TYPE_INT_ARRAY: return true
		TYPE_STRING_ARRAY: return true
	return false

func isBetweenTimes(now,timeStart,timeEnd) -> bool:
	var timeStartNorm = getSecondsTilMidnight(timeStart)
	var timeEndNorm   = getSecondsTilMidnight(timeEnd)
	var timeNowNorm   = getSecondsTilMidnight(now)
	
	if timeStartNorm <= timeEndNorm: # midnight not included
		if timeNowNorm >= timeStartNorm and timeNowNorm <= timeEndNorm:
			return true
	else: #midnight included
		if timeNowNorm >= timeStartNorm or timeNowNorm <= timeEndNorm:
			return true
	return false
	

func isImageFile(path):
	if typeof(path) != TYPE_STRING: return false
	var pathArr = path.split(".")
	if pathArr.size() < 2: return false
	var ending = pathArr[pathArr.size()-1].to_lower()
	match ending:
		"bmp": return true
		"jpg": return true
		"jpeg": return true
		"png": return true
	return false
		

func isInArray(val,arr):
	match typeof(arr):
		TYPE_ARRAY:
			pass
		var typeArr:
			return false
	
	return arr.has(val)

func isInStr(a,b):
	if typeof(a) != TYPE_STRING: return false
	if typeof(b) == TYPE_STRING:
		if a == b:
			return true
	if typeof(b) == TYPE_ARRAY or typeof(b) == TYPE_STRING_ARRAY:
		if a in b:
			return true
	return false

func isNumber(val):
	match typeof(val):
		TYPE_INT: return true
		TYPE_REAL: return true
	return false
	
func inherit(child, parent):
	
	match typeof(parent):
		TYPE_DICTIONARY:
			var result = mergeInto(child, parent, false)
			
			if parent.has("isTemplate") and parent.isTemplate == true and (!child.has("isTemplate") or child.isTemplate != true):
				result.erase("isTemplate")
			
			return result
		TYPE_ARRAY:
			var result = child.duplicate()
			
			for p in parent:
				result = mergeInto(result, p, false)
				
			return result
				
		var parentType:
			GameManager.logOut(["inherit: unexpected type of parent:",parentType],"ERROR")
			
func intRandom(v):
	match typeof(v):
		TYPE_INT:
			return v
		TYPE_REAL,TYPE_STRING:
			return int(v)
		TYPE_ARRAY:
			if v.size() >= 2:
				return rng.randi_range(intRandom(v[0]),intRandom(v[1]))
			return intRandom(v[0])
		var vType:
			GameManager.logOut(["intRandom: unexpected type of v: ",vType],"ERROR")
	return 0

func mergeDateTime(dtSource,dtTarget)->Dictionary:
	var dtTargetdt = dtTarget.duplicate()
	
	for key in dtSource:
		if !dtTargetdt.has(key): dtTargetdt[key] = dtSource[key]
		
	return dtTargetdt

func mergeDictBoolOr(source,target):
	
	for key in source:
		var entry = source[key]
		target[key] = target.get(key,false) or entry
	
	return target

func mergeInto(source,target,inplace = true):
	var commandSigns = {
		"ignoreNonexistent": "?",
		"ignoreExistent":    "!",
		"deleteEntry":       "-",
		"replaceEntry":      "§",
		"append":            "+",
		"prepend":           "*"
	}
	var commandSignsValues = commandSigns.values()
	
	if inplace == false: target = target.duplicate(true)
	
	for key in source:
		var skey
		var commands = []
		
		for i in range(key.length()):
			if commandSignsValues.has(key[i]):
				commands.append(key[i])
			else:
				skey = key.substr(i,key.length()-i)
				break

		var valueSource = source[key]
		var typeSource = typeof(valueSource)
		
		var valueTarget
		var typeTarget
		if target.has(skey):
			valueTarget = target[skey]
			typeTarget = typeof(valueTarget)
		else:
			valueTarget = null
			typeTarget = TYPE_NIL
		
		if commands.has(commandSigns.ignoreNonexistent):
			if typeTarget == TYPE_NIL: continue
		elif commands.has(commandSigns.ignoreExistent):
			if typeTarget != TYPE_NIL: continue
		elif commands.has(commandSigns.deleteEntry):
			if typeSource == TYPE_BOOL and valueSource == true and typeTarget != TYPE_NIL: target.erase(key)
			continue
		
		if typeTarget == TYPE_NIL:
			target[skey] = valueSource
		
		elif typeSource == TYPE_ARRAY and typeTarget == TYPE_ARRAY:
			if commands.has(commandSigns.replaceEntry):
				target[skey] = valueSource
			elif commands.has(commandSigns.prepend):
				var values = valueTarget
				target[skey] = valueSource.duplicate()
				for i in range(values.size()): target[skey].append(values[i])
			else:
				for i in range(valueSource.size()): target[skey].append(valueSource[i])
				
		elif typeSource == TYPE_DICTIONARY and typeTarget == TYPE_DICTIONARY:
			target[skey] = mergeInto(valueSource,valueTarget)
		
		elif (typeSource == TYPE_STRING and typeTarget == TYPE_STRING):
			if commands.has(commandSigns.prepend):
				target[skey] = valueSource + valueTarget
			elif commands.has(commandSigns.append):
				target[skey] = valueTarget + valueSource
			else:
				target[skey] = valueSource
		elif ((typeSource == TYPE_INT and typeTarget == TYPE_INT) or
			(typeSource == TYPE_REAL and typeTarget == TYPE_REAL) or 
			(typeSource == TYPE_BOOL and typeTarget == TYPE_BOOL)):
				target[skey] = valueSource
				
	
	return target

func regex(s):
	return cache_regex.get(s)

func regexLoad(s):
	print("REGEX ",s)
	var reg = RegEx.new()
	reg.compile(s)
	return reg

func stringFormat(string:String)->String:
	var result = ""
	
	var stringArr = string.split(".")
	
	for stringPart in stringArr:
		var s = stringPart.strip_edges()
		if !s.empty():
			s[0] = s[0].to_upper()
			result += s
			result += ". "
			
	return result
	
func stringEraseFromTo(s:String,from:int,to:int)->String:
	var result = s
	var length
	if to == -1:
		length = s.length() - from
	elif to >= from:
		length = to - from + 1
	else:
		result = stringEraseFromTo(s,from,-1)
		result = stringEraseFromTo(result,0,to)
		return result
	
	result.erase(from,length)
		
	return result
	
func stringReplace(s:String,from:int,to:int,replaceWith:String)->String:
	var result = stringEraseFromTo(s,from,to)
	result = result.insert(from,replaceWith)
	return result
	
func stringSubstrFromTo(s:String,from:int,to:int)->String:
	var result = s
	var length
	if to == -1:
		length = s.length() - from
	elif to >= from:
		length = to - from + 1
	else:
		var r1 = stringSubstrFromTo(s,from,-1)
		var r2 = stringSubstrFromTo(s,0,to)
		return r2+r1
		
	return result.substr(from,length)

func texture(path):
	return cache_texture.get(path)

func textureLoad(path):	
	var mods = GameManager.getActiveMods()
	
	for modId in mods:
		var fpath = GameManager.getModFolder(modId)+"/media/"+path
		if fileExists(fpath):
			var image = Image.new()
			image.load(fpath)
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			return texture
			
	if fileExists("res://media/"+path):
		var texture = load("res://media/"+path)
		return texture
	
	elif fileExists(path):
		var image = Image.new()
		image.load(path)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		return texture
		
	GameManager.logOut(["Error loading texture: ",path])
	
	var texture = preload("res://media/texture/missingTexture.jpg")
	return texture
	 
	
func time(now,arg):
	var nowDict = getDateTime(now)
	var target = nowDict.duplicate()
	
	match arg:
		"NEXT_SUN":
			var daysTilTarget = 7 - nowDict.weekday
			if daysTilTarget > 7: daysTilTarget -= 7
			target = getUnixTime(datetimeResetTime(target))
			target += daysTilTarget * 86400
		"NEXT_MON":
			var daysTilTarget = 8 - nowDict.weekday # Cant do mod since 7%7=0
			if daysTilTarget > 7: daysTilTarget -= 7
			target = getUnixTime(datetimeResetTime(target))
			target += daysTilTarget * 86400
		_:
			var argArr = arg.split(":")
			var hour = 0
			var minute = 0
			var second = 0
			match argArr.size():
				2:
					hour = int(argArr[0])
					minute = int(argArr[1])
				3:
					hour = int(argArr[0])
					minute = int(argArr[1])
					second = int(argArr[2])
			
			target.hour = hour
			target.minute = minute
			target.second = second
				
			var unixNow = getUnixTime(nowDict)
			var unixTarget = getUnixTime(target)
			
			if unixNow > unixTarget: 
				unixTarget += 86400
				target = getDateTime(unixTarget)
		
	return target
	
	