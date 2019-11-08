extends Control

var categories = {}
var ccategories = {}
var ccategoryIndex = 0
var ccategory = {}
var clabel = ""
var ctarget = ""
var cpage = 0

var imageFiles = []
var cimage = 0

var items = {}
var citem = {}

var tbs
var cbutton = -1

var imageFileContainer

func button2index(button):
	match button:
		7: return 0
		8: return 1
		9: return 2
		4: return 3
		6: return 4
		1: return 5
		2: return 6
		3: return 7
	print("Invalid button: "+str(button))
	return 0
	


func execute(button):
	#var category = categories[ccategory]
	#var category = categories[ccategories[ccategory]]
	var positon = button2index(button)
	var index = pos2Index(positon)
	
	if index == -1:
		cpage = max(0,cpage-1)
		showCCategory()
		return OK
	elif index == -2:
		cpage += 1
		showCCategory()
		return OK
		
	var ccategoryItems = getCategoryItems(ccategory)
	var ccategorySize = ccategoryItems.size()
	
	
	if ccategorySize <= index or typeof(ccategoryItems[index]) != TYPE_DICTIONARY:
		return
	
	if ccategoryItems[index].has("result"):
		var result = ccategoryItems[index].result
		for key in result:
			var entry = result[key]
			var currentTarget = key
			if !ctarget.empty(): currentTarget = ctarget
			
			match typeof(entry):
				TYPE_NIL:
					citem.erase(currentTarget)
				TYPE_STRING, TYPE_REAL, TYPE_INT, TYPE_BOOL:
					citem[currentTarget] = entry
				TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_STRING_ARRAY, TYPE_REAL_ARRAY:
					if !citem.has(currentTarget) or typeof(citem[currentTarget]) != TYPE_ARRAY: citem[currentTarget] = []
					for i in entry:
						citem[currentTarget].append(i)
				var entryType:
					print("Unexpected Value Type ",entryType," for entry ",key)
					
	
	if ccategoryItems[index].has("categories"):
		ccategories = ccategory[index].categories
		ccategoryIndex = 0
	elif ccategoryItems[index].has("jump"):
		ccategory = categories[ccategoryItems[index].jump]
		showCCategory()
		return
	else:
		ccategoryIndex += 1
		
	if ccategoryIndex < ccategories.size():
		var id = ccategories[ccategoryIndex]
		if typeof(id) == TYPE_STRING:
			ccategory = categories[id]
			ctarget = ""
			clabel = ""
		elif typeof(id) == TYPE_DICTIONARY:
			ccategory = categories[id.category]
			if id.has("target"): 
				ctarget = id.target
			else:
				ctarget = ""
			if id.has("label"): 
				clabel = id.label
			else:
				clabel = ""
	else:
		finalizeCItem()
		set_cimage(cimage+1)
		if cimage >= imageFiles.size():
			print("COMPLETE")
			print(items)
		else:
			startItem(cimage)
		
	showCCategory()

func finalizeCItem():
	var path = imageFiles[cimage]
	var pathArr = path.split("/")
	var id = pathArr[pathArr.size()-1]
	items[id] = citem
	

func getCategoryItems(category):
	var categoryItems = []
	
	match typeof(category):
		TYPE_ARRAY:
			categoryItems = category
		TYPE_DICTIONARY:
			var order = category.get("order",[])
			var items = category.get("items",{})
			for itemId in order:
				if typeof(itemId) == TYPE_STRING and items.has(itemId):
					categoryItems.append(items[itemId])
				else:
					categoryItems.append(null)
	return categoryItems

func loadCategoires():
	var file = File.new()
	file.open("res://data/tools/itemTag.json", file.READ)
	var text = file.get_as_text()
	file.close()
	var temp = JSON.parse(text)
	if temp.error == OK:
		var fcategories = temp.result
		categories = fcategories
	else:
		print("Error loading Categories: "+str(temp.error))



func set_cimage(value):
	get_tree().call_group("uiImageFileButton","set_cimage",value)
	cimage = value

func pos2Index(pos:int):
	if cpage == 0:
		if ccategory.size() <= 8 or pos <= 6:
			return pos
		return -2
	
	if pos == 5: return -1
	
	var index = cpage * 6 + 1 + pos
	if pos == 6 or pos == 7: index -= 1 # because the previous page-button is on 5
	
	if pos == 7 and ccategory.size() > cpage * 6 + 7:
		index  = -2
	
	return index
		

func showCCategory():
	$VBoxContainer/HBoxContainer/VBoxContainer/Label.text = clabel
	#cpage = 0
	for pos in range(8):
		var ind = pos2Index(pos)
		if ind == -1:
			tbs[pos].setTexture(null)
			tbs[pos].setLabel("<--")
			tbs[pos].setColor(null)
		elif ind == -2:
			tbs[pos].setTexture(null)
			tbs[pos].setLabel("-->")
			tbs[pos].setColor(null)
		
		#var ccategorySize = 0
		var ccategoryItems = getCategoryItems(ccategory)
		var ccategorySize = ccategoryItems.size()
		#match typeof(ccategory):
		#	TYPE_ARRAY:
		#		ccategorySize = ccategory.size()
		#		ccategoryItems = ccategory
		#	TYPE_DICTIONARY:
		#		var order = ccategory.get("order",[])
		#		var items = ccategory.get("items",{})
		#		ccategorySize = order.size()
		#		for itemId in order:
		#			if typeof(itemId) == TYPE_STRING and items.has(itemId):
		#				ccategoryItems.append(items[itemId])
		#			else:
		#				ccategoryItems.append(null)
		
		if ccategorySize > ind and typeof(ccategoryItems[ind]) == TYPE_DICTIONARY:
			if ccategoryItems[ind].has("texture"):
				tbs[pos].setTexture(Util.texture(ccategory[ind].texture))
			else:
				tbs[pos].setTexture(null)
			if ccategoryItems[ind].has("text"):
				tbs[pos].setLabel(ccategoryItems[ind].text)
			else:
				tbs[pos].setLabel("")
			if ccategoryItems[ind].has("color"):
				if typeof(ccategoryItems[ind].color) == TYPE_ARRAY:
					var colors = []
					for color in ccategoryItems[ind].color:
						colors.append(GameManager.getColor(color).rgb)
					tbs[pos].setGradient(colors)
				else:
					tbs[pos].setColor(GameManager.getColor(ccategoryItems[ind].color).rgb)
			else:
				tbs[pos].setColor(null)
		else:
			tbs[pos].setTexture(null)
			tbs[pos].setLabel("")
			tbs[pos].setColor(null)

func startItem(fileIndex):
	set_cimage(fileIndex)
	var file = imageFiles[cimage]
	var texture = Util.texture(file)
	$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = texture
	citem = {"texture":file}
	ccategory = categories["start"]
	ctarget = ""
	clabel = ""
	showCCategory()
	
	
	

func _on_SelectFolderDialog_dir_selected(dir):
	imageFiles = []
	var files = Util.getFilesInFolder(dir)
	for imageFile in files:
		if(Util.isImageFile(imageFile)):
			var path = dir+"/"+imageFile
			imageFiles.append(path)
	
	if imageFiles.size() == 0:
		print("Error: no images found in folder")
		return
	
	for i in imageFileContainer.get_children():
    	i.queue_free()
	
	var imageFileButtonPL = preload("res://scenes/tools/itemTag/ImageFileButton.tscn")
	
	
	#for imageFile in imageFiles:
	for i in range(imageFiles.size()):
		var imageFile=imageFiles[i]
		var fileNameParts = imageFile.split("/")
		var fileName = fileNameParts[fileNameParts.size()-1]
		var imageFileButtonInstance = imageFileButtonPL.instance()
		imageFileButtonInstance.setItemFile(fileName, imageFile, i)
		imageFileContainer.add_child(imageFileButtonInstance)
	
	startItem(0)
	
func _process(delta):
	if Input.is_action_pressed("ui_upleft"):
		cbutton = 7
	elif Input.is_action_pressed("ui_up"):
		cbutton = 8
	elif Input.is_action_pressed("ui_upright"):
		cbutton = 9
	elif Input.is_action_pressed("ui_left"):
		cbutton = 4
	elif Input.is_action_pressed("ui_right"):
		cbutton = 6
	elif Input.is_action_pressed("ui_downleft"):
		cbutton = 1
	elif Input.is_action_pressed("ui_down"):
		cbutton = 2
	elif Input.is_action_pressed("ui_downright"):
		cbutton = 3
	elif cbutton > 0:
		execute(cbutton)
		cbutton = -1
		
func _ready():

	tbs  = [
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TB_7,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TB_8,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TB_9,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TB_4,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TB_6,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/TB_1,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/TB_2,
		$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/TB_3
	]
	imageFileContainer = $VBoxContainer/HBoxContainer/ImageFileScrollContainer/ImageFileContainer
	loadCategoires()
	$SelectFolderDialog.popup_centered()


func _on_OpenFolderButton_pressed():
	$SelectFolderDialog.popup_centered()



func _on_SaveButton_pressed():
	$InputDialog.showDialog("Mod ID")

func _on_MainMenuButton_pressed():
	return get_tree().change_scene("res://scenes/titleScreen/titleScreen.tscn")
	
func inputResult(value):
	var resultCode = saveMod(value)
	match resultCode:
		ERR_PARAMETER_RANGE_ERROR:
			get_tree().call_group("inputDialog","dialogError","The value must not be empty")
		ERR_ALREADY_EXISTS:
			get_tree().call_group("inputDialog","dialogError","The folder already exists") 
		OK:
			get_tree().call_group("inputDialog","dialogClose",{})
		_:
			get_tree().call_group("inputDialog","dialogError","Unexpected Error: "+resultCode) 
	
	
func saveMod(modId):
	var modFolder = GameManager.folderMod+"/"+modId
	if modId.empty():
		return ERR_PARAMETER_RANGE_ERROR
		#get_tree().call_group("inputDialog","dialogError","The value must not be empty") 
	elif(Util.folderExists(modFolder)):
		return ERR_ALREADY_EXISTS
		#get_tree().call_group("inputDialog","dialogError","The folder already exists") 
	
	var modInfo = {
			"name": modId,
			"description": "Created with ItemTag"
		}
	Util.folderCreate(GameManager.folderMod,modId)
	Util.data2File(modInfo,modFolder+"/info.json",true)
	
	var itemFolder = modFolder + "/item"
	var itemFile = itemFolder + "/items.json"
	var mediaFolder = modFolder + "/media"
	
	Util.folderCreate(modFolder,"item")
	Util.folderCreate(modFolder,"media")
	
	var dir = Directory.new()

	
	var itemToSave = {}
	for key in items:
		var fileName = Util.getFilename(items[key].texture)
		dir.copy(items[key].texture, mediaFolder+"/"+fileName)
		items[key].texture = "mods://"+modId+"/media/"+fileName
		items[key].covers = GameManager.getItemCoveredBodyParts(items[key])
		itemToSave[modId+"_"+key] = items[key]
		
		
	Util.data2File(itemToSave,itemFile,true)
	
	return OK
