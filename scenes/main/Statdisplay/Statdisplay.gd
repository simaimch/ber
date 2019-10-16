extends HBoxContainer

export var LabelText:String
export var Stat:String

func _ready():
	$StatNameLabel.text = LabelText

func updateUI(CurrentUi):
	var currentStat = GameManager.PlayerData.stat[Stat].current#GameManager.getValueFromPath("PlayerData.stat."+Stat+".current")
	var percentage = int(currentStat/100)
	
	$Control/ColorRect.rect_size.x = percentage
	$Control/PercentageLabel.text = str(percentage)+"%"
	
	if percentage >= 90:
		$Control/ColorRect.color = Color("018d36")
	elif percentage >= 80:
		$Control/ColorRect.color = Color("3baa34")
	elif percentage >= 70:
		$Control/ColorRect.color = Color("94c11e")
	elif percentage >= 60:
		$Control/ColorRect.color = Color("dfdc01")
	elif percentage >= 50:
		$Control/ColorRect.color = Color("fdea00")
	elif percentage >= 40:
		$Control/ColorRect.color = Color("f9b234")
	elif percentage >= 30:
		$Control/ColorRect.color = Color("f29200")
	elif percentage >= 20:
		$Control/ColorRect.color = Color("ea4e1b")
	elif percentage >= 10:
		$Control/ColorRect.color = Color("e6342a")
	else:
		$Control/ColorRect.color = Color("be1623")