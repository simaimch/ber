extends VBoxContainer

var skillPL = preload("res://scenes/detailsMenu/Skill.tscn")

func clearChildren():
	for i in get_children():
    	i.queue_free()

func updateUI(CurrentUi):
	clearChildren()
	for skillId in GameManager.PlayerData.skill:
		var skillLevel = GameManager.PlayerData.skill[skillId]
		var skill = GameManager.getSkill(skillId)
		var skillInstance = skillPL.instance()
		skillInstance.setSkill(skill,skillLevel)
		add_child(skillInstance)
