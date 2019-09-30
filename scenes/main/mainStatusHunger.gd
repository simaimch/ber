extends Label

func updateUI(CurrentUi):
	if CurrentUi.ShowPlayerStat == true:
		show()
		var stat = CurrentUi.PlayerStat.hunger.current
		text = str(stat/100) + "%"
		if stat >= 7000:
			set("custom_colors/font_color",Color(0,1,0))
		elif stat >= 3000:
			set("custom_colors/font_color",Color(1,1,0))
		else:
			set("custom_colors/font_color",Color(1,0,0))
	else:
		hide()