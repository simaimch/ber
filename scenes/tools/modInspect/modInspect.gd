extends PanelContainer


onready var openModDialog:FileDialog = $OpenModDialog
onready var tree:Tree = $VBoxContainer/HSplitContainer/Tree

var dirTemplates:String = "res://data/tools/modInspect"
var templates:Dictionary = {}

var modInfo:Dictionary
var modPath:String

var items = {}

var item2TreeItem = {}

func _ready():
	loadTemplates()	

func _on_LoadButton_pressed():
	openModDialog.popup_centered()

func _on_OpenModDialog_dir_selected(dir):
	modLoad(dir)

func _on_Tree_item_selected():
	var selectedItem = tree.get_selected()
	for itemID in item2TreeItem:
		var treeItem = item2TreeItem[itemID]
		if treeItem == selectedItem:
			selectItem(itemID)
			break

func error(msg:String,title:String="ERROR"):
	get_tree().call_group("error","showError",{"msg":msg,"title":title})

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
	
	modInfo = Util.loadJSONfromFile(infoPath)
	
	tree.clear()
	
	var rootItem:TreeItem = tree.create_item()
	rootItem.set_text(0,modInfo.get("name","Name Missing"))
	
	var itemFiles = Util.getFilesInFolder(Util.path([modPath,"item"]))
	if itemFiles.size() > 0:
		var itemsItem: TreeItem = tree.create_item(rootItem)
		itemsItem.set_text(0,"items")
		for itemFile in itemFiles:
			var itemsInFile = Util.loadJSONfromFile(Util.path([modPath,"item",itemFile]))
			for itemID in itemsInFile:
				var itemInFile = itemsInFile[itemID]
				items[itemID] = itemInFile
		for itemID in items:
			var item = items[itemID]
			var itemItem:TreeItem = tree.create_item(itemsItem)
			itemItem.set_text(0,itemID)
			item2TreeItem[itemID] = itemItem
	
func selectItem(itemID:String):
	pass


