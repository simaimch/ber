extends Control

func formatInt(i,format="00"):
	var result = ""
	if format == "00":
		if i < 10 and i >= 0:
			result = "0"+str(i)
		else:
			result = str(i)
	return result
	
func formatMoney(money):
	money = int(money)
	var text = str(money/100) + ","+formatInt(money%100,"00")+" €"
	return text
		
func formtTime(time,timeFormat="{day}.{month}.{year} {hour}:{minute}"):
	var dateTime = OS.get_datetime_from_unix_time (time)
	var day = formatInt(dateTime.day,"00")
	var month = formatInt(dateTime.month,"00")
	var year = formatInt(dateTime.year,"00")
	
	var hour = formatInt(dateTime.hour,"00")
	var minute = formatInt(dateTime.minute,"00")
	var second = formatInt(dateTime.second,"00")

	return timeFormat.format({"day": day,"month": month,"year": year,"hour": hour,"minute": minute,"second":second})

func formatTimeHHMMSS(t):
	t = int(t)
	var seconds = t % 60
	var minutes = (t % 3600)/60
	var hours = t/3600
	
	var result = ""
	if hours > 0:
		result = formatInt(hours,"00")+":"
	result += formatInt(minutes,"00")+":"+formatInt(seconds,"00")
	return result

func getFilesInFolder(path):
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
	
func string2DateTime(s):
	#DD.MM.YYYY
	#hh:mm:ss or hh:mm
	#combine date and time with a single space in between, example:DD.MM.YYYY hh:mm:ss
	var result = {"year":1970,"month":1,"day":1,"hour":0,"minute":0,"second":0}
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
	
func getAge(now, bday):
	var nowDict = getDateTime(now)
	var bdayDict= getDateTime(bday)
	
	if (nowDict.month > bdayDict.month) or (nowDict.month == bdayDict.month and nowDict.day >= bdayDict.day):
		return nowDict.year - bdayDict.year
	else:
		return nowDict.year - bdayDict.year - 1
		
func getDaysTilDate(now,target,anyyear = true):
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
	
func getHoursTilTime(now,target):
	var nowDict = getDateTime(now)
	var targetDict= getDateTime(target)
	
	return int(targetDict.hour - nowDict.hour + 24*getDaysTilDate(now,target,false))
	
func getDateTime(dt):
	if typeof(dt) == TYPE_DICTIONARY: return dt
	if typeof(dt) == TYPE_STRING: return string2DateTime(dt)
	if typeof(dt) == TYPE_INT: return OS.get_datetime_from_unix_time(dt)
	if typeof(dt) == TYPE_REAL: return OS.get_datetime_from_unix_time(int(dt))
	print("Unexpected Parameter of Type "+str(typeof(dt))+" in Util.getDateTime():"+str(dt))
	return OS.get_datetime_from_unix_time(0)
	
func getUnixTime(time):
	if typeof(time) == TYPE_DICTIONARY: return OS.get_unix_time_from_datetime(time)
	if typeof(time) == TYPE_STRING: return OS.get_unix_time_from_datetime(string2DateTime(time))
	if typeof(time) == TYPE_INT: return time
	if typeof(time) == TYPE_REAL: return int(time)
	return "Unexpected Parameter of Type "+str(typeof(time))+" in Util.getUnixTime()"
	return 0
	
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
	
func bigger(a,b):
	var ta = typeof(a)
	var tb = typeof(b)
	
	if ta == TYPE_STRING: a = int(a)
	elif ta != TYPE_INT and ta != TYPE_REAL: return false
	
	if tb == TYPE_STRING: b = int(b)
	elif tb != TYPE_INT and tb != TYPE_REAL: return false
	
	return (a > b)
	

func equals(a,b):
	var ta = typeof(a)
	var tb = typeof(b)
	
	if (ta == TYPE_REAL or ta == TYPE_INT) and (tb == TYPE_REAL or tb == TYPE_INT):
		if a == b: return true
	
	if ta == TYPE_BOOL and tb != TYPE_BOOL:
		b = bool(b)
		
	#if tb == TYPE_BOOL and ta != TYPE_BOOL:
	#	a = bool(a)
	
	if a == b:
		return true
		
	return false
	
	
func fileExists(path):
	var file2Check = File.new()
	return file2Check.file_exists(path)

func isArray(a):
	match typeof(a):
		TYPE_ARRAY: return true
		TYPE_INT_ARRAY: return true
		TYPE_STRING_ARRAY: return true
	return false

func isInStr(a,b):
	if typeof(a) != TYPE_STRING: return false
	if typeof(b) == TYPE_STRING:
		if a == b:
			return true
	if typeof(b) == TYPE_ARRAY or typeof(b) == TYPE_STRING_ARRAY:
		if a in b:
			return true
	return false

func mergeInto(source,target):
	if isArray(source) and isArray(target):
		var result = [] # to make sure the result is TYPE_ARRAY
		for i in target: result.append(i)
		for i in source: result.append(i)
		return result
	if typeof(source) != TYPE_DICTIONARY: return {}
	if typeof(target) != TYPE_DICTIONARY: return {}
	
	for key in source:
		var value = source[key]
		if !target.has(key):
			target[key] = value
		elif target.has("+"+key):
			target[key] = mergeInto(value, target["+"+key])
			
	return target
		
func texture(path):
	if fileExists(path):
		return load(path)
	return preload("res://media/texture/missingTexture.jpg")
	
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
		
	return target
	