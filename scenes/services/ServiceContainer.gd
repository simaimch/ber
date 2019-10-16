extends VBoxContainer

var servicePL = preload("res://scenes/services/Service.tscn")
	

func clearChildren():
	for i in get_children():
    	i.queue_free()
		
	

func updateUI(CurrentUi):
	clearChildren()
	
	for serviceId in CurrentUi.Services.available:
		var service = GameManager.getService(serviceId)
		if CurrentUi.Services.category == "" or CurrentUi.Services.category == service.category:
			var serviceInstance = servicePL.instance()
			serviceInstance.setService(service)
			add_child(serviceInstance)
			

