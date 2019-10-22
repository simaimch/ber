extends Control

var categories = {}
var ccategory = "start"

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
	var category = categories[ccategory]
	var index = button2index(button)
	print("DAS")
	if category.size() <= index or typeof(category[index]) != TYPE_DICTIONARY:
		return
	print("ASD")
	var result = category[index].result
	for key in result:
		var entry = result[key]
		if typeof(entry) == TYPE_STRING:
			citem[key] = entry
		elif typeof(entry) == TYPE_ARRAY:
			citem[key] = entry
	
	showCategory(category[index].next)

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

func showCategory(cat):
	if cat == "COMPLETE":
		var path = imageFiles[cimage]
		var pathArr = path.split("/")
		var id = pathArr[pathArr.size()-1]
		items[id] = citem
		set_cimage(cimage+1)
		if cimage >= imageFiles.size():
			print("COMPLETE")
			print(items)
		else:
			startItem(cimage)
		return
	
	ccategory = cat
	if !categories.has(ccategory): return
	var category = categories[ccategory]
	
	for i in range(8):
		if category.size() > i and typeof(category[i]) == TYPE_DICTIONARY:
			tbs[i].texture_normal = Util.texture(category[i].texture)
		else:
			tbs[i].texture_normal = null

func startItem(fileIndex):
	set_cimage(fileIndex)
	var file = imageFiles[cimage]
	var texture = Util.texture(file)
	$VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TextureRect.texture = texture
	citem = {"texture":file}
	showCategory("start")
	
	
	

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
		
		Util.folderCreate(modFolder,"item")
		
		var itemToSave = {}
		for key in items:
			itemToSave[value+"_"+key] = items[key]
		Util.data2File(itemToSave,itemFile,true)
		
		get_tree().call_group("inputDialog","dialogClose",{})
