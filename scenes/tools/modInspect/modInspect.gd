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
var itemsItem:TreeItem
var item2TreeItem = {}

var cache_texture

func _ready():
	cache_texture = Cache.new(funcref(self,"textureLoad"),200)
	loadTemplates()

func _on_LoadButton_pressed():
	openModDialog.popup_centered()

func _on_OpenModDialog_dir_selected(dir):
	modLoad(dir)

func _on_SaveButton_pressed():
	modSave()

func _on_Tree_item_selected():
	
	var itemOverviewContainer = $VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer
	var detailsContainer = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer
	
	var selectedItem = tree.get_selected()
	
	if selectedItem == rootItem:
		detailsContainer.show()
		itemOverviewContainer.hide()
		selectInfo()
		return
		
	if selectedItem == itemsItem:
		detailsContainer.hide()
		itemOverviewContainer.show()
		var itemOverview = $VBoxContainer/HSplitContainer/PanelContainer/ScrollContainer/OverviewContainer
		Util.clearChildren(itemOverview)
		for itemID in data.items:
			var textureRect:TextureRect = TextureRect.new()
			textureRect.rect_min_size = Vector2(200,200)
			textureRect.expand = true
			textureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			var dc_item = data_changed.get("items",{}).get(itemID,{})
			var item = Util.mergeInto(data.items[itemID],dc_item,false)
			setTexture(item.get("texture"),textureRect)
			
			itemOverview.add_child(textureRect)
		return
	
	for itemID in item2TreeItem:
		var treeItem = item2TreeItem[itemID]
		if treeItem == selectedItem:
			detailsContainer.show()
			itemOverviewContainer.hide()
			selectItem(itemID)
			break



func error(msg:String,title:String="ERROR"):
	get_tree().call_group("error","showError",{"msg":msg,"title":title})

#func focusExited(entry,input,label):
#	var value = input.text
#	if entryIsValid(entry,value):
#		label.set("custom_colors/font_color", Color(0,0,0))
#	else:
#		label.set("custom_colors/font_color", Color(1,0,0))

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
			"Int":
				var input

				input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/HSliderContainer.duplicate(0)
				
				var slider = input.get_node("HSlider")
				
				slider.min_value = entry.get("valueMin",0)
				slider.max_value = entry.get("valueMax",100)
				
				var sliderLabel = input.get_node("Label")
				slider.connect("value_changed",self,"sliderChanged",[sliderLabel,label,entryKey,category,id])
				grid.add_child(input)

				if currentValue: slider.value = currentValue
				
				#input.connect("focus_exited",self,"focusExited",[entry,input,label])
			"String":
				var input
				match entry.get("editorTool","singleline"):
					"singleline":
						input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/LineEdit.duplicate(0)
						#input.connect("text_changed",self,"textChanged",[input,entryKey,category,id])
						input.connect("text_changed",self,"textChanged",[label,entryKey,category,id])
					"multiline":
						input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/TextEdit.duplicate(0)
						#input.connect("text_changed",self,"textChanged",[input,entryKey,category,id])
						input.connect("text_changed",self,"textChanged",[input,label,entryKey,category,id])
				grid.add_child(input)

				if currentValue: input.text = currentValue
				
				input.connect("focus_exited",self,"focusExited",[entry,input,label])
			"StringSelect":
				var input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/OptionButton.duplicate(0)
				var values = entry.get("values",[]) #valid Values
				for value in values:
					input.add_item(value)
				grid.add_child(input)
				
				if !currentValue: currentValue = "EMPTY"	
				input.text = currentValue
				
				var onUpdateRefresh = entry.get("editorRefresh",false)
				
				input.connect("item_selected",self,"itemSelected",[input,label,entryKey,category,id,onUpdateRefresh])
				
				if currentValue in values:
					input.select(values.find(currentValue))	
				else:
					
					input.add_item(currentValue)
					input.select(values.size())
					label.set("custom_colors/font_color", Color(1,0,0))
				
			"Texture":
				var input = $VBoxContainer/HSplitContainer/PanelContainer/CenterContainer/GridTemplate/TextureContainer.duplicate(0)
				var texturePath
				
				#texturePath = currentValue
				#texturePath = currentValue
				#var texturePathRelative = Util.path(["media",currentValue])
				
				#var texturePathAbsolute = Util.path([modPath,texturePathRelative])
				
				var textureRect = input.get_node("Texture")
				#textureText.texture = Util.textureCreate(texturePathAbsolute)
				setTexture(currentValue,textureRect)
				
				var pathInput = input.get_node("Path")
				pathInput.text = str(currentValue)
				
				pathInput.connect("text_changed",self,"textChanged",[label,entryKey,category,id])
				pathInput.connect("focus_exited",self,"setTexture",[pathInput,textureRect])
				
				grid.add_child(input)
				

func inputValue(input):
	match typeof(input):
		TYPE_OBJECT:
			match input.get_class():
				"HSlider":
					return input.value
				"OptionButton":
					return input.text
				"LineEdit","TextEdit":
					return input.text
	return input

func itemSelected(selctionID, input, label, entry,category,id,onUpdateRefresh):
	var newValue = input.get_item_text(selctionID)
	updateEntry(newValue,label,entry,category,id)
	if onUpdateRefresh:
		match category:
			"items":
				selectItem(id)

func loadTemplates():
	var templateFiles= Util.getFilesInFolder(dirTemplates)
	for templateFile in templateFiles:
		var templateId = templateFile.get_basename()
		templates[templateId] = Util.loadJSONfromFile(Util.path([dirTemplates,templateFile]))

func modLoad(path:String):
	data_changed = {}
	
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
	item2TreeItem = {}
	var itemFiles = Util.getFilesInFolder(Util.path([modPath,"item"]))
	if itemFiles.size() > 0:
		itemsItem = tree.create_item(rootItem)
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
	if !value: 
		if entry.get("required",false): return false
		return true
		
	match entry.get("valueType","String"):
		"Int":
			return (typeof(value) == TYPE_INT or typeof(value) == TYPE_REAL)
		"String","Texture":
			var s = str(value)
			s = s.strip_edges()
			return !s.empty()
		"StringSelect":
			if value in entry.get("values",[]): return true
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
	
func setTexture(path,textureRect:TextureRect):
	path = inputValue(path)
	#var texturePathRelative = Util.path(["media",path])
	#var texturePathAbsolute = Util.path([modPath,texturePathRelative])	
	#textureRect.texture = Util.textureCreate(texturePathAbsolute)
	textureRect.texture = cache_texture.get(path)

func sliderChanged(value,sliderlabel,label,entryKey,category,id):
	textChanged(value,label,entryKey,category,id)
	sliderlabel.text = str(value)

func textChanged(input,label,entryKey,category,id):
	updateEntry(inputValue(input),label,entryKey,category,id)

func textureLoad(path):
	var texturePathRelative = Util.path(["media",path])
	var texturePathAbsolute = Util.path([modPath,texturePathRelative])	
	return Util.textureCreate(texturePathAbsolute)
	
func updateEntry(value,label,entryKey,category,id):
	var template
	if !data_changed.has(category): data_changed[category] = {}
	if !data_changed[category].has(entryKey): data_changed[category][entryKey] = {}
	match(category):
		"info":
			data_changed[category][entryKey] = value
			template = templates.get("info",{})
		"items":
			if !data_changed[category].has(id): data_changed[category][id] = {}
			data_changed[category][id][entryKey] = value
			template = templates.get("item",{})
			var item = Util.mergeInto(data.items[id],data_changed[category][id],false)
			itemValidityUpdate(item,template,item2TreeItem[id])

	var entry = template.get(entryKey,{})
	if entryIsValid(entry,value):
		label.set("custom_colors/font_color", Color(0,0,0))
	else:
		label.set("custom_colors/font_color", Color(1,0,0))



