extends Area3D

#var NearbyBodies : Array[InteractableItem]
#var highlightedObject: InteractableItem = null
#
#func _process(_delta: float) -> void:
	#
	#if (highlightedObject != null):
		#highlightedObject.unfocus()
	#if Globals.buildMode == Globals.buildMode:
		#HighlightNearestItem()
		#
#func _input(event: InputEvent)-> void:
	#if(event.is_action_pressed("Delete") and Globals.buildMode ==  Globals.buildMode):
		#PickupNearestItem()
		#
#func FindNearestItem() -> InteractableItem:
	## finds the nearest item in the pickup area
	#var nearestItem: InteractableItem = null
	#var nearestItemDistance : float = INF
	## find the nearest item in the area
	#for item in NearbyBodies:
		#if (item.global_position.distance_to(global_position) < nearestItemDistance):
			#nearestItemDistance = item.global_position.distance_to(global_position)
			#nearestItem = item
	#return nearestItem
	#
#func HighlightNearestItem():
	#if Globals.Mode == Globals.viewMode:
		#return
	#var nearestItem: InteractableItem = FindNearestItem()
	#if highlightedObject != null:
		#highlightedObject.unfocus()
		#Globals.FurnitureHighlighted = false
	#if nearestItem != null:
		#highlightedObject = nearestItem
		#nearestItem.focus()	
		#Globals.FurnitureHighlighted = true
	#
#func PickupNearestItem():
	#var nearestItem: InteractableItem = FindNearestItem()
	## remove item from view
	#if (nearestItem != null):
		#nearestItem.destroy()
		#NearbyBodies.remove_at(NearbyBodies.find(nearestItem))
		#var itemPrefab = nearestItem.scene_file_path
		## adding item to inventory, not needed right now
		##for i in ItemTypes.size():
			##if (ItemTypes[i].ItemModelPrefab != null and 
			##ItemTypes[i].ItemModelPrefab.resource_path == itemPrefab):
				### replace with pick up item handler
				##print("Item id:" + str(i) + " Item Name:" + ItemTypes[i].ItemName)
				###OnItemPickedUp.emit(ItemTypes[i])
				##return
		##print("Item not found")
#
#func OnObjectEnteredArea(body: Node3D):
	#if(body is InteractableItem):
		#NearbyBodies.append(body)
#
#func OnObjectExitedArea(body: Node3D):
	#if(body is InteractableItem and NearbyBodies.has(body)):
		#NearbyBodies.remove_at(NearbyBodies.find(body))
