extends RichTextLabel

var textBackup

func resetText():
	text = textBackup

func updateUI(CurrentUi):
	#text = CurrentUi.Text
	bbcode_text = CurrentUi.Text
	
	textBackup = bbcode_text
	scroll_to_line(0)

func _ready():
    get_tree().get_root().connect("size_changed", self, "resetText")


func _on_TextMain_meta_clicked(meta):
	print(meta)
