extends Node
class_name InventoryHandler

# signal to PlayerController
signal OnItemChanged(item: ItemData)
signal OnItemPlaced()
signal ZoomIn()
signal ZoomOut()
signal ChangeCamera()

#@export var InventorySlotPrefab : PackedScene = preload('res://Inventory/InventoryUI/InventorySlot.tscn')
@export var ItemTypes : Array[ItemData] = []
#@onready var menuButtons : Array[RichTextLabel] = [%LeftArrow, %RightArrow, %Mode, %ZoomIn, %ZoomOut, %Camera]
@onready var InventorySlots : Array[Node] = $InventoryBox/Panel/MarginContainer/GridContainer.get_children()
@onready var InventoryHoverStyle = preload("res://Assets/Textures/BrownUIHover.tres")
@onready var InventoryNormalStyle = preload("res://Assets/Textures/brownUI.tres")
#var ItemSlotsCount : int = 24

var selectedSlot = 0
var selectedButton = 1


func _ready() -> void:
	# create Inventory
	for i in ItemTypes.size():
		#var slot = InventorySlotPrefab.instantiate() as InventorySlot
		#InventoryGrid.add_child(slot)
		#$InventoryBox/Panel/MarginContainer/GridContainer.call_deferred("add_child", slot)
		var slot = InventorySlots[i]
		slot.InventorySlotID = i
		if i < ItemTypes.size():
			if ItemTypes[i] != null:
				slot.FillSlot(ItemTypes[i])
		#InventorySlots.append(slot)
	# focus button
	$".".release_focus()
	updateActionHints()
	focus(selectedSlot, selectedSlot)

#func _unhandled_input(_event: InputEvent)-> void:
func _process(delta: float)-> void:
	if Input.is_action_just_pressed("Exit"):
		if $Tutorial.visible:
			$UiSounds/tutOff.play()
			$Tutorial.visible = false
		else:
			$UiSounds/tutOn.play()
			$Tutorial.visible = true
		return
	
	#var click = false
	var place = false
	var delete = false
	var uiRight = false
	var uiLeft = false
	var buildToggle = false
	var cameraToggle = false
	
	if Input.is_action_just_pressed("Place"):
		place = true
	elif Input.is_action_just_pressed("UIRight"):
		uiRight = true
	elif Input.is_action_just_pressed("UILeft"):
		uiLeft = true
	elif Input.is_action_just_pressed("BuildMode"):
		buildToggle = true
	elif Input.is_action_just_pressed("Camera"):
		cameraToggle = true
	elif Input.is_action_just_pressed("Delete"):
		delete = true
	
	if (uiRight or uiLeft) and not Globals.InventorySelected and (Globals.Mode == Globals.buildMode):
		# changing selected invetory slot
		$UiSounds/inventoryShuffle.play()
		var previously_selected = selectedSlot
		if uiRight:
			selectedSlot = (selectedSlot + 1) % InventorySlots.size()
		elif uiLeft:
			selectedSlot = (selectedSlot - 1) % InventorySlots.size()
		
		focus(previously_selected, selectedSlot)
			
	elif buildToggle and not Globals.InventorySelected:
		# toggle inventory show button
		$UiSounds/modeToggle.play()
		if Globals.Mode == Globals.buildMode:
			Globals.Mode = Globals.viewMode
			$InventoryBox.visible = false
		elif Globals.Mode == Globals.viewMode:
			Globals.Mode = Globals.buildMode
			$InventoryBox.visible = true
	elif cameraToggle:
		$UiSounds/cameraToggle.play()
		if %Camera.text == "man":
			%Camera.text = "face_down"
		elif %Camera.text == "face_down":
			%Camera.text = "man"
		ChangeCamera.emit()
	elif place and (Globals.Mode == Globals.buildMode):
		if Globals.InventorySelected:
			# placing ghost block
			$UiSounds/furniturePlaced.play()
			OnItemPlaced.emit()
		else:
			# selecting furniture
			$UiSounds/inventorySelected.play()
			OnItemChanged.emit(InventorySlots[selectedSlot].SlotData)

	elif delete and Globals.InventorySelected:
		$UiSounds/cancel.play()
		OnItemChanged.emit(null)
	updateActionHints()
	
func updateActionHints():
	for action in $ActionBar/GridContainer.get_children():
		action.visible = false
	%Inv.visible = true
	
	if InventorySlots[selectedSlot].SlotFilled:
		%Place.visible = true
		
	if Globals.InventorySelected:
		%Place.visible = true
		%Rotate.visible = true
		%Cancel.visible = true
		
	if Globals.FurnitureHighlighted and not Globals.InventorySelected:
		%Delete.visible = true

		
func focus(prev: int, curr: int):
	
	InventorySlots[prev].add_theme_stylebox_override("normal", InventoryNormalStyle)
	InventorySlots[curr].add_theme_stylebox_override("normal", InventoryHoverStyle)
