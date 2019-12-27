extends HBoxContainer

var skill

func setSkill(s, level):
	skill = s
	$Label.text = skill.label
	
	$Progress10.setValue(level)

func _on_Skill_mouse_entered():
	get_tree().call_group("tooltip","showTooltip",{"text":skill.description,"followMouse":true})


func _on_Skill_mouse_exited():
	get_tree().call_group("tooltip","hideTooltip",{})
	
