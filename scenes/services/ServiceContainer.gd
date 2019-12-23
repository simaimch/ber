extends VBoxContainer

var servicePL = preload("res://scenes/services/Service.tscn")
	

func clearChildren():
	for i in get_children():
		i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for serviceId in CurrentUi.Services.available:
		var service = GameManager.getServiceById(serviceId)
		var serviceCategory = GameManager.getValue(service,"category","Category Missing")
		match CurrentUi.Services.get("category",""):
		#if CurrentUi.Services.category == "" or CurrentUi.Services.category == service.category:
			"", serviceCategory:
				var serviceInstance = servicePL.instance()
				serviceInstance.setService(service)
				add_child(serviceInstance)
			

