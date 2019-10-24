extends Control

var categories = {}
var ccategories = {}
var ccategoryIndex = 0
var ccategory = {}
var ctarget = ""

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
	var index = button2index(button)
	
	if ccategory.size() <= index or typeof(ccategory[index]) != TYPE_DICTIONARY:
		return
	
	if ccategory[index].has("result"):
		var result = ccategory[index].result
		for key in result:
			var entry = result[key]
			var currentTarget = key
			if !ctarget.empty(): currentTarget = ctarget
			if typeof(entry) == TYPE_STRING:
				citem[currentTarget] = entry
			elif typeof(entry) == TYPE_ARRAY:
				if !citem.has(currentTarget) or typeof(citem[currentTarget]) != TYPE_ARRAY: citem[currentTarget] = []
				for i in entry:
					citem[currentTarget].append(i)
	
	if ccategory[index].has("categories"):
		ccategories = ccategory[index].categories
		ccategoryIndex = 0
	elif ccategory[index].has("jump"):
		ccategory = categories[ccategory[index].jump]
		showCCategory()
		return
	else:
		ccategoryIndex += 1
		
	if ccategoryIndex < ccategories.size():
		var id = ccategories[ccategoryIndex]
		if typeof(id) == TYPE_STRING:
			ccategory = categories[id]
			ctarget = ""
		elif typeof(id) == TYPE_DICTIONARY:
			ccategory = categories[id.category]
			ctarget = id.target
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
	
	#if cimage >= imageFiles.size():
	#	print("COMPLETE")
	#	print(items)
	#else:
	#	startItem(cimage)
	#return

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

func showCCategory():
	#if cat == "COMPLETE":
	#	var path = imageFiles[cimage]
	#	var pathArr = path.split("/")
	#	var id = pathArr[pathArr.size()-1]
	#	items[id] = citem
	#	set_cimage(cimage+1)
	#	if cimage >= imageFiles.size():
	#		print("COMPLETE")
	#		print(items)
	#	else:
	#		startItem(cimage)
	#	return
	
	#ccategory = cat
	#if !categories.has(ccategory): return
	#var category = categories[ccategory]
	
	for i in range(8):
		if ccategory.size() > i and typeof(ccategory[i]) == TYPE_DICTIONARY:
			if ccategory[i].has("texture"):
				tbs[i].setTexture(Util.texture(ccategory[i].texture))
			else:
				tbs[i].setTexture(null)
			if ccategory[i].has("text"):
				tbs[i].setLabel(ccategory[i].text)
			else:
				tbs[i].setLabel("")
			if ccategory[i].has("color"):
				tbs[i].setColor(GameManager.getColor(ccategory[i].color).rgb)
			else:
				tbs[i].setColor(null)
		else:
			tbs[i].setTexture(null)
			tbs[i].setLabel("")
			tbs[i].setColor(null)

func startItem(fileIndex):
	set_cimage(fileIndex)
	var file = imageFiles[cimage]
	var texture = Util.texture(file)
	$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = texture
	citem = {"texture":file}
	ccategory = categories["start"]
	ctarget = ""
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
	$SaveFileDialog.current_dir = GameManager.folderMod
	$SaveFileDialog.current_path= GameManager.folderMod
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


func _on_SaveFileDialog_file_selected(path):
	var saveFile = File.new()
	saveFile.open(path, File.WRITE)
	saveFile.store_line(to_json(items))
	saveFile.close()
	print("Saved at "+path)


func _on_SaveButton_pressed():
	$InputDialog.showDialog("Mod ID")

func _on_MainMenuButton_pressed():
	return get_tree().change_scene("res://scenes/titleScreen/titleScreen.tscn")
	
func inputResult(value):
	var modFolder = GameManager.folderMod+"/"+value
	if value.empty():
		get_tree().call_group("inputDialog","dialogError","The value must not be empty") 
	elif(Util.folderExists(modFolder)):
		get_tree().call_group("inputDialog","dialogError","The folder already exists") 
	else:
		var modInfo = {
				"name": value,
				"description": "Created with ItemTag"
			}
		Util.folderCreate(GameManager.folderMod,value)
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
			items[key].texture = "mods://"+value+"/media/"+fileName
			itemToSave[value+"_"+key] = items[key]
			
			
		Util.data2File(itemToSave,itemFile,true)
		
		get_tree().call_group("inputDialog","dialogClose",{})
