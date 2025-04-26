extends Control
var currentTab = 0
var itemButton = preload("res://Scenes/Apps/Inventory/item_button.tscn")
var rodButton = preload("res://Scenes/Apps/Inventory/rod_button.tscn")
var selectedItem:Resource = null

@onready var phoneMenu = $"../Ui/Phone"

# Called when the node enters the scene tree for the first time.
func _ready():
	hideEverything()
	createItemButtons()

func hideEverything():
	$BG/OptionsHolder/ItemTexture.texture = null
	$BG/OptionsHolder/Name.text = ""
	$BG/OptionsHolder/Desc.text = "Select an item to get started"
	$BG/OptionsHolder/ReUse.hide()
	for child in $BG/OptionsHolder/OptionsContainer/VBoxContainer.get_children():
		child.hide()

func createItemButtons():
	for item:Item in Globals.itemInventory:
		if $"BG/TabBar/0/GridContainer".get_node_or_null(item.displayName):
			#print("Found: ",item.displayName)
			continue
		var button = itemButton.instantiate()
		button.item = item
		button.name = item.displayName
		button.setup()
		button.connect("showItemDesc",itemButtonPressed)
		$"BG/TabBar/0/GridContainer".add_child(button)
		#print("Created: ", item.displayName)

	for rodItem:ItemRod in Globals.rods:
		if $"BG/TabBar/1/GridContainer".get_node_or_null(rodItem.displayName):
			continue
		var button = rodButton.instantiate()
		button.rod = rodItem
		button.name = rodItem.displayName
		button.setup()
		button.connect("showItemDesc",rodButtonPressed)
		$"BG/TabBar/1/GridContainer".add_child(button)

func rodButtonPressed(rod:ItemRod):
	if selectedItem == rod:
		return
	selectedItem = rod
	$BG/OptionsHolder/ReUse.hide()
	for node:Button in $BG/OptionsHolder/OptionsContainer/VBoxContainer.get_children():
		node.hide()
	#Texture Control
	$BG/OptionsHolder/ItemTexture.texture = rod.texture
	$BG/OptionsHolder/Name.text = rod.displayName
	$BG/OptionsHolder/Desc.text = rod.description
	if Globals.currentRod != selectedItem:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()

func itemButtonPressed(item:Item):
	if selectedItem == item:
		return
	
	selectedItem = item
	#Texture Control
	$BG/OptionsHolder/ItemTexture.texture = item.texture
	$BG/OptionsHolder/Name.text = item.displayName
	$BG/OptionsHolder/Desc.text = item.description	
	#Buttons
	#Trashing Control
	if item.trashable:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Trash.hide()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Trash.show()
	
	if item.mergeable:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/MergeButton.show()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/MergeButton.hide()
	
	if item.consumable:
		$BG/OptionsHolder/ReUse.visible = item.consumable #Why did i write this?
		$BG/OptionsHolder/ReUse.button_pressed = (item in Globals.reUseItems)
	else:
		$BG/OptionsHolder/ReUse.hide()
	
	#Detecting Script Functions
	#Usable
	if item.has_method("equipped"):
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
	
	#Check for if item is already in use
	var cancelable:bool = item.has_method("unequipped") #Check to see if cancel function exists
	if item in Globals.inUseItems:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.visible = cancelable
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.hide()

func _on_tab_bar_tab_changed(tab):
	self.get_node("BG/TabBar/" + str(currentTab)).hide()
	self.get_node("BG/TabBar/" + str(tab)).show()
	currentTab = tab

func setItemEquipped(equipped:bool):
	if equipped:
		var cancelable:bool = selectedItem.has_method("unequipped")
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.visible = cancelable
		if selectedItem in Globals.inUseItems:
			return
		#Equip item
		Globals.inUseItems.append(selectedItem)
		$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem.displayName).showInUse(true)
		selectedItem.equipped()
	else:
		selectedItem.unequipped()
		#Removes item from inUseItems
		Globals.inUseItems.erase(selectedItem)
		$BG/OptionsHolder/ReUse.button_pressed = false

func setRodEquipped(equipped:bool):
	if equipped:
		var node = $"BG/TabBar/1/GridContainer".get_node_or_null(
			Globals.currentRod.displayName
			)
		if node:
			node.showInUse(false)
		Globals.currentRod = selectedItem
		$"BG/TabBar/1/GridContainer".get_node(selectedItem.displayName).showInUse(true)
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
		var rc:Control = $"../RodContainer"
		var rod:PackedScene = Globals.currentRod.scene
		rc.get_child(0).queue_free()
		rc.add_child(rod.instantiate())

func _on_use_button_pressed():
	if selectedItem is Item:
		setItemEquipped(true)
	elif selectedItem is ItemRod:
		setRodEquipped(true)
	
func _on_cancel_pressed():
	if selectedItem is Item:
		setItemEquipped(false)
	elif selectedItem is ItemRod:
		setRodEquipped(false)
	#Updating stuff
	$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem.displayName).showInUse(false)
	$BG/OptionsHolder/ReUse.button_pressed = false
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.hide()
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()

func _on_exit_button_pressed():
	self.hide()
	hideEverything()
	phoneMenu.show()

func _on_re_use_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if selectedItem not in Globals.inUseItems:
			_on_use_button_pressed()
		Globals.reUseItems.append(selectedItem)
	else:
		#Top 10 worst lines of code ever
		if Globals.reUseItems.has(selectedItem):
			Globals.reUseItems.erase(selectedItem)
	
func _on_visibility_changed() -> void:
	if self.visible:
		#Checks to see if item exists
		createItemButtons()
		if selectedItem and selectedItem.count <= 0:
			hideEverything()
		
		for button in $"BG/TabBar/0/GridContainer".get_children():
			button.update() #Swag
	else:
		selectedItem = null
