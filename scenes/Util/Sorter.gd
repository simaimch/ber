extends Node

class_name Sorter

static func sortByIndex(a, b):
	if int(a) < int(b):
		return true
	return false
		
static func sortByIndexInv(a ,b):
	return sortByIndex(b,a)

static func sortByPriority(a,b):
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
