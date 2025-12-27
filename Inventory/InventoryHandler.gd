extends Node
class_name InventoryHandler
signal OnItemChanged(item: ItemData)
signal BuildModeChanged(new_build_mode: bool)
@export var ItemSlotsCount : int = 20
@export var InventoryGrid : GridContainer
@export var InventorySlotPrefab : PackedScene = preload('res://Inventory/InventoryUI/InventorySlot.tscn')
@export var ItemTypes : Array[ItemData] = []

var InventorySlots : Array[InventorySlot] = []
var selectedSlot = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in ItemSlotsCount:
		var slot = InventorySlotPrefab.instantiate() as InventorySlot
		InventoryGrid.add_child(slot)
		slot.InventorySlotID = i
		if i < ItemTypes.size():
			if ItemTypes[i] != null:
				slot.FillSlot(ItemTypes[i])
		InventorySlots.append(slot)
	InventorySlots[0].grab_focus()
	
		
	#var itemData : ItemData;
	#itemData.ItemName = "Floor"
	#itemData.Icon = preload("res://Textures/BoxIcon.png")
	#itemData.ItemModelPrefab = preload("res://Inventory/Floor.tscn")
	#InventorySlots[1].FillSlot(itemData)

func _input(event: InputEvent)-> void:
	var previously_selected = selectedSlot
	if Input.is_action_just_pressed("NextItem"):
		selectedSlot += 1
	if Input.is_action_just_pressed("PreviousItem"):
		selectedSlot -= 1
	if previously_selected != selectedSlot:
		
		if (selectedSlot < 0):
			selectedSlot += InventorySlots.size()
		elif selectedSlot >= InventorySlots.size():
			selectedSlot -= InventorySlots.size()
		if InventorySlots[selectedSlot].SlotFilled:
			# slot should have item in it
			BuildModeChanged.emit(true)
		else:
			BuildModeChanged.emit(false)
		OnItemChanged.emit(InventorySlots[selectedSlot].SlotData)
			
		focus(previously_selected, selectedSlot)
func focus(prev: int, curr: int):
	InventorySlots[prev].release_focus()
	InventorySlots[curr].grab_focus()

func PickupItem(item : ItemData):
	# TODO don't need to actually pickup item
	pass
	#for slot in InventorySlots:
		#if (!slot.SlotFilled):
			#slot.FillSlot(item)
			#break
