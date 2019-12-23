extends Object

class_name Cache

var cache_size:int
var cache_history = []
var cache_items = {}
var funcRefLoad:FuncRef

func _init(funcRefLoadEntry:FuncRef, size:int = 50).():
	funcRefLoad = funcRefLoadEntry
	cache_size = size

func _get(property:String):
	if !cache_items.has(property): 
		loadEntry(property)
	else:
		touchEntry(property)
	return cache_items[property]

func addEntry(property:String):
	return funcRefLoad.call_func(property)

func loadEntry(property:String):
	cache_items[property] = addEntry(property)
	cache_history.push_front(property)
	removeSurplus()
	
func removeSurplus():
	var entriesToRemove:int = cache_history.size() - cache_size
	if entriesToRemove <= 0: return
	
	for i in range(entriesToRemove):
		var entryToRemove:String = cache_history.pop_back()
		cache_items.erase(entryToRemove)
	
func touchEntry(property:String):
	cache_history.erase(property)
	cache_history.push_front(property)
