extends Control

func formatInt(i,format="00"):
	var result = ""
	if format == "00":
		if i < 10 and i >= 0:
			result = "0"+str(i)
		else:
			result = str(i)
	return result
		
func formtTime(time,timeFormat="{day}.{month}.{year} {hour}:{minute}"):
	var dateTime = OS.get_datetime_from_unix_time (time)
	var day = formatInt(dateTime.day,"00")
	var month = formatInt(dateTime.month,"00")
	var year = formatInt(dateTime.year,"00")
	
	var hour = formatInt(dateTime.hour,"00")
	var minute = formatInt(dateTime.minute,"00")

	return timeFormat.format({"day": day,"month": month,"year": year,"hour": hour,"minute": minute})
