extends RichTextLabel

var textBackup

func resetText():
	text = textBackup

func updateUI(CurrentUi):
	text = CurrentUi.Text
	textBackup = text
	scroll_to_line(0)

func _ready():
    get_tree().get_root().connect("size_changed", self, "resetText")
