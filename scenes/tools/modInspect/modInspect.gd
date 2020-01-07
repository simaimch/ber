extends PanelContainer

const ORIGINATION = "_ORIGINATION"

onready var grid:GridContainer = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/ModInfoGrid
onready var openModDialog:FileDialog = $OpenModDialog
onready var tree:Tree = $VBoxContainer/HSplitContainer/Tree

var dirTemplates:String = "res://data/tools/modInspect"
var templates:Dictionary = {}

#var modInfo:Dictionary
var modPath:String

#var items = {}
var data = {}
var data_changed = {}

var rootItem:TreeItem
var item2TreeItem = {}

func _ready():
	loadTemplates()	

func _on_LoadButton_pressed():
	openModDialog.popup_centered()

func _on_OpenModDialog_dir_selected(dir):
	modLoad(dir)

func _on_SaveButton_pressed():
	modSave()

func _on_Tree_item_selected():
	var selectedItem = tree.get_selected()
	
	if selectedItem == rootItem:
		selectInfo()
		return
	
	for itemID in item2TreeItem:
		var treeItem = item2TreeItem[itemID]
		if treeItem == selectedItem:
			selectItem(itemID)
			break



func error(msg:String,title:String="ERROR"):
	get_tree().call_group("error","showError",{"msg":msg,"title":title})

func gridPopulate(template,dsaved,dchanged,category,id):
	Util.clearChildren(grid)
	for entryKey in template:
		var entry = template[entryKey]
		
		var condition = entry.get("condition",null)
		if condition:
			var conditionParam = Util.mergeInto(dchanged,dsaved,false)
			if !GameManager.checkConditionParameter(condition,conditionParam):
				continue
		
		var label:Label = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/Label.duplicate(0)
		label.text = entryKey
		grid.add_child(label)
		label.show()
		
		if entry.get("required",false) and (!dsaved.has(entryKey) and !dchanged.has(entryKey)):
			label.set("custom_colors/font_color", Color(1,0,0))
		
		var currentValue = null
		if dchanged.has(entryKey): currentValue = dchanged.get(entryKey)
		elif dsaved.has(entryKey): currentValue = dsaved.get(entryKey)
		
		match entry.get("valueType","String"):
			"String":
				var input
				match entry.get("editorTool","singleline"):
					"singleline":
						input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/LineEdit.duplicate(0)
						input.connect("text_changed",self,"textChanged",[entryKey,category,id])
					"multiline":
						input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/TextEdit.duplicate(0)
						input.connect("text_changed",self,"textChanged",[input,entryKey,category,id])
				grid.add_child(input)

				if currentValue: input.text = currentValue
			"StringSelect":
				var input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/OptionButton.duplicate(0)
				var values = entry.get("values",[]) #valid Values
				for value in values:
					input.add_item(value)
				grid.add_child(input)
				
				#if currentValue: 
				if !currentValue: currentValue = "EMPTY"	
				input.text = currentValue
				
				var onUpdateRefresh = entry.get("editorRefresh",false)
				
				input.connect("item_selected",self,"itemSelected",[input,entryKey,category,id,onUpdateRefresh])
				
#				input.select(values.find(input.text))
				if currentValue in values:
					input.select(values.find(currentValue))	
				else:
					
					input.add_item(currentValue)
					input.select(values.size())
					label.set("custom_colors/font_color", Color(1,0,0))
				
			"Texture":
				var input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/TextureContainer.duplicate(0)
				var texturePath
				
				texturePath = currentValue
				
				texturePath = Util.path([modPath,"media",texturePath])
				
				input.get_node("Texture").texture = Util.textureCreate(texturePath)
				#input.Texture.texture = Util.textureCreate(texturePath)
				
				grid.add_child(input)
				

func itemSelected(selctionID, input, entry,category,id,onUpdateRefresh):
	var newValue = input.get_item_text(selctionID)
	updateEntry(newValue,entry,category,id)
	if onUpdateRefresh:
		match category:
			"item":
				selectItem(id)

func loadTemplates():
	var templateFiles= Util.getFilesInFolder(dirTemplates)
	for templateFile in templateFiles:
		var templateId = templateFile.get_basename()
		templates[templateId] = Util.loadJSONfromFile(Util.path([dirTemplates,templateFile]))

func modLoad(path:String):
	modPath = path
	var infoPath = Util.path([modPath,"info.json"])
	
	if !Util.fileExists(infoPath):
		error("File missing:\n"+infoPath)
		return
	
	data.info = Util.loadJSONfromFile(infoPath)
	
	tree.clear()
	
	rootItem = tree.create_item()
	rootItem.set_text(0,data.info.get("name","Name Missing"))
	
	data.items = {}
	var itemFiles = Util.getFilesInFolder(Util.path([modPath,"item"]))
	if itemFiles.size() > 0:
		var itemsItem: TreeItem = tree.create_item(rootItem)
		itemsItem.set_text(0,"items")
		for itemFile in itemFiles:
			var itemsInFile = Util.loadJSONfromFile(Util.path([modPath,"item",itemFile]))
			for itemID in itemsInFile:
				var itemInFile = itemsInFile[itemID]
				itemInFile[ORIGINATION] = itemFile
				data.items[itemID] = itemInFile
		for itemID in data.items:
			var item = data.items[itemID]
			var itemItem:TreeItem = tree.create_item(itemsItem)
			itemItem.set_text(0,itemID)
			item2TreeItem[itemID] = itemItem
			
	for itemID in data.items:
		var item = data.items[itemID]
		var templateItem = templates.get("item",{})
		itemValidityUpdate(item,templateItem,item2TreeItem[itemID])

func entryIsValid(entry:Dictionary,value)->bool:
	match entry.get("valueType","String"):
		"String":
			return true
		"StringSelect":
			if value in entry.get("values",[]): return true
		"Texture":
			return true
	return false
		

func itemValidityUpdate(item:Dictionary,template:Dictionary,treeItem:TreeItem):
	for templateEntryID in template:
		var entry = template[templateEntryID]
		var condition = entry.get("condition",null)
		
		if condition and !GameManager.checkConditionParameter(condition,item): continue
		
		if !entryIsValid(entry,item.get(templateEntryID)):
			treeItem.set_custom_color(0,Color(1,0,0))
			return
	treeItem.set_custom_color(0,Color(0,0.8,0))

func modSave():
	var dcinfo = data_changed.get("info",{})
	for entryID in dcinfo:
		var entry = dcinfo[entryID]
		data.info[entryID] = entry
		
	
	Util.data2File(data.info,Util.path([modPath,"info.json"]))
	
	var dcitem = data_changed.get("items",{})
	for itemID in dcitem:
		var item = dcitem[itemID]
		for entryID in item:
			var entry = item[entryID]
			data.items[itemID][entryID] = entry
			
	for itemID in data.items:
		var item = data.items[itemID]
		var keys = item.keys()
		for key in keys:
			if key.begins_with("_"): item.erase(key)
			
	Util.data2File(data.items,Util.path([modPath,"item","items.json"]),true)
	
	data_changed = {}
	
	rootItem.set_text(0,data.info.name)

func selectInfo():	
	var templateInfo = templates.get("info",{})
	gridPopulate(templateInfo,data.info,data_changed.get("info",{}),"info",null)
	
		

func selectItem(itemID:String):
	var data_item = data.items.get(itemID,{})
	var datac_item= data_changed.get("items",{}).get(itemID,{})
	
	var templateInfo = templates.get("item",{})
	gridPopulate(templateInfo,data_item,datac_item,"items",itemID)

func textChanged(text,entry,category,id):
	updateEntry(text,entry,category,id)
			
func updateEntry(text,entry,category,id):
	if typeof(text) == TYPE_OBJECT: text = text.text
	if !data_changed.has(category): data_changed[category] = {}
	if !data_changed[category].has(entry): data_changed[category][entry] = {}
	match(category):
		"info":
			data_changed[category][entry] = text
		"items":
			if !data_changed[category].has(id): data_changed[category][id] = {}
			data_changed[category][id][entry] = text



