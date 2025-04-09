extends Control
var currentTab = 0
var itemButton = preload("res://Scenes/item_button.tscn")
var selectedItem:Item = null

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
			continue
		
		var itemName = item.displayName
		var button = itemButton.instantiate()
		button.item = item
		button.name = itemName
		button.setup()
		button.connect("showItemDesc",buttonPressed)
		$"BG/TabBar/0/GridContainer".add_child(button)

func buttonPressed(item:Item):
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
	var cancelable:bool = item.has_method("cancel") #Check to see if cancel function exists
	if item in Globals.inUseItems:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.visible = cancelable
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.hide()
		
func updateItems(_tab):
	pass


func _on_tab_bar_tab_changed(tab):
	self.get_node("BG/TabBar/" + str(currentTab)).hide()
	self.get_node("BG/TabBar/" + str(tab)).show()
	currentTab = tab
	


func _on_use_button_pressed():
	var cancelable:bool = selectedItem.has_method("unequipped")
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.visible = cancelable
	if selectedItem in Globals.inUseItems:
		return
		
	#Equip item
	Globals.inUseItems.append(selectedItem)
	$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem.displayName).showInUse(true)
	selectedItem.equipped()
	


func _on_cancel_pressed():
	selectedItem.unequipped()
	#Removes item from inUseItems
	Globals.inUseItems.erase(selectedItem)
	#Updating stuff
	$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem.displayName).showInUse(false)
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.hide()
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()
	$BG/OptionsHolder/ReUse.button_pressed = false

func _on_exit_button_pressed():
	self.hide()
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
