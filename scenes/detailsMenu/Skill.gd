extends HBoxContainer

var skill

func setSkill(s, level):
	skill = s
	$Label.text = skill.label
	
	for i in range(0,9):
		if level > i:
			$Display.get_child(i).color = Color(1,0,0,1) 
		else:
			$Display.get_child(i).color = Color(0,0,0,1) 

func _on_Skill_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":skill.description,"followMouse":true})


func _on_Skill_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
	