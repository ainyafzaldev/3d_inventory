extends Node
class_name InventoryHandler

# signal to PlayerController
signal OnItemChanged(item: ItemData)
signal OnItemPlaced()
# signal to Interaction Handler
signal BuildModeChanged(new_build_mode: bool)

@export var ItemSlotsCount : int = 20
@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload('res://Inventory/InventoryUI/InventorySlot.tscn')
@export var ItemTypes : Array[ItemData] = []
@onready var menuButtons : Array[RichTextLabel] = [%LeftArrow, %RightArrow, %Mode, %ZoomIn, %ZoomOut, %Camera]
@onready var InventorySlots : Array[InventorySlot] = []

@onready var InventoryHoverStyle = preload("res://Assets/Textures/BrownUIHover.tres")
@onready var InventoryNormalStyle = preload("res://Assets/Textures/BrownUI.tres")

var selectedSlot = 0
var selectedButton = 1

# when the hover is over the bottom two inventory arrows
# false when the hover is in the top menu buttons
var arrowHover: bool = true

func _ready() -> void:
	# create Inventory
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		if i < ItemTypes.size():
			if ItemTypes[i] != null:
				slot.FillSlot(ItemTypes[i])
		InventorySlots.append(slot)
	# focus button
	$".".release_focus()
	%RightArrow.grab_focus()
	updateActionHints()

func _unhandled_input(_event: InputEvent)-> void:
	
	var click = false
	var place = false
	var delete = false
	var uiRight = false
	var uiLeft = false
	
	if Input.is_action_just_pressed("Click"):
		click = true
	elif Input.is_action_just_released("Place"):
		place = true
	elif Input.is_action_just_pressed("UIRight"):
		uiRight = true
	elif Input.is_action_just_pressed("UILeft"):
		uiLeft = true
	elif Input.is_action_just_pressed("Delete"):
		delete = true
	
	var buttonName = menuButtons[selectedButton].name
	
	if click:
		if arrowHover:
			# changing selected invetory slot
			
			var previously_selected = selectedSlot
			if buttonName == "RightArrow":
				selectedSlot = (selectedSlot + 1) % InventorySlots.size()
			elif buttonName == "LeftArrow":
				selectedSlot = (selectedSlot - 1) % InventorySlots.size()
			
			focus(previously_selected, selectedSlot)
			
		else:
			# toggle menu buttons
			pass
		
	elif place and arrowHover:
		if Globals.InventorySelected:
			# placing ghost block
			Globals.InventorySelected = false
			OnItemPlaced.emit()
			BuildModeChanged.emit(false)
		else:
			# showing ghost block
			Globals.InventorySelected = true
			# place selected inventory ghost block
			if InventorySlots[selectedSlot].SlotFilled:
				# slot should have item in it
				BuildModeChanged.emit(true)
			else:
				BuildModeChanged.emit(false)
				
			OnItemChanged.emit(InventorySlots[selectedSlot].SlotData)
	
	elif (uiRight or uiLeft) and not Globals.InventorySelected:
		# changing selected menu button
		menuButtons[selectedButton].release_focus()
		
		if uiRight:
			selectedButton = (selectedButton + 1) % menuButtons.size()
		else:
			selectedButton = (selectedButton - 1) % menuButtons.size()
		
		menuButtons[selectedButton].grab_focus()
		buttonName = menuButtons[selectedButton].name
		
		if buttonName == "LeftArrow" or buttonName == "RightArrow":
			arrowHover = true
		else:
			arrowHover = false
	elif delete and Globals.InventorySelected:
		BuildModeChanged.emit(false)
	updateActionHints()
	
func updateActionHints():
			
	var mode = "MenuBarHover"
	if arrowHover and not Globals.InventorySelected:
		mode = "InventoryHover"
	elif arrowHover and Globals.InventorySelected:
		mode = "InventorySelected"
		
	for action in $ActionBar/GridContainer.get_children():
		action.visible = false
	%Move.visible = true
	
	if mode == "MenuBarHover":
		%Left.visible = true
		%Right.visible = true
		%Toggle.visible = true
	elif mode == "InventoryHover":
		%Left.visible = true
		%Right.visible = true
		%Click.visible = true
		if InventorySlots[selectedSlot].SlotFilled:
			%Place.visible = true
	elif mode == "InventorySelected":
		%Place.visible = true
		%Rotate.visible = true
		%Cancel.visible = true
		
		
	if Globals.FurnitureHighlighted and mode != "InventorySelected":
		%Delete.visible = true

		
func focus(prev: int, curr: int):
	InventorySlots[prev].add_theme_stylebox_override("normal", InventoryNormalStyle)
	InventorySlots[curr].add_theme_stylebox_override("normal", InventoryHoverStyle)
