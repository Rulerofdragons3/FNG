extends Control
var currentTab = 0
var itemButton = preload("res://Scenes/item_button.tscn")
var selectedItem = null

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
	for item in Globals.itemInventory:
		if !FileAccess.file_exists("res://Items/ItemDat/" + item + ".json"):
			error_string("Couldn't find file: " + item + ".json")
			continue
		
		var button = itemButton.instantiate()
		button.itemID = item
		button.name = item
		button.setup()
		button.connect("showItemDesc",buttonPressed)
		$"BG/TabBar/0/GridContainer".add_child(button)

func buttonPressed(itemID):
	selectedItem = JSON.parse_string(FileAccess.get_file_as_string(
		"res://Items/ItemDat/" + itemID + ".json"
	))
	var data = selectedItem
	
	#Texture Control
	if "texture" in data and data["texture"] != "":
		$BG/OptionsHolder/ItemTexture.texture = load("res://Assets/Items/" + data["texture"])
	else:
		$BG/OptionsHolder/ItemTexture.texture = load("res://Assets/Buttons/ExitUP.png")
	#Naming control	
	if "name" in data:
		$BG/OptionsHolder/Name.text = data["name"]
	else:
		$BG/OptionsHolder/Name.text = itemID
	#Description control
	if "desc" in data:
		$BG/OptionsHolder/Desc.text = data["desc"]
	else:
		$BG/OptionsHolder/Desc.text = ""
	
	#Buttons
	#Trashing Control
	if "trashable" in data and !data["trashable"]:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Trash.hide()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/Trash.show()
	
	if "mergeable" in data:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/MergeButton.show()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/MergeButton.hide()
	
	if "consumable" in data:
		$BG/OptionsHolder/ReUse.visible = data["consumable"]
		$BG/OptionsHolder/ReUse.button_pressed = (data["id"] in Globals.reUseItems)
		
	else:
		$BG/OptionsHolder/ReUse.hide()
	
	#Detecting Script Functions
	if "script" not in data:
		return
	
	var script:Script = load("res://Items/ItemScripts/" + data["script"])
	#Usable
	if script.has_method("equipped"):
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()
	else:
		$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
	
	#Check for if item is already in use
	var cancelable:bool = script.has_method("cancel") #Check to see if cancel function exists
	if selectedItem["id"] in Globals.inUseItems:
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
	var script:Script = load("res://Items/ItemScripts/" + selectedItem["script"])
	var cancelable:bool = script.has_method("unequipped")
	
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.hide()
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.visible = cancelable
	if selectedItem["id"] in Globals.inUseItems:
		return
		
	#Equp item
	Globals.inUseItems.append(selectedItem["id"])
	$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem["id"]).showInUse(true)
	script.equipped(selectedItem)
	#print(Globals.inUseItems)
	


func _on_cancel_pressed():
	var script:Script = load("res://Items/ItemScripts/" + selectedItem["script"])
	script.unequipped(selectedItem)
	#Removes item from inUseItems
	Globals.inUseItems.remove_at(Globals.inUseItems.find(selectedItem["id"]))
	#Updating stuff
	$BG/TabBar.get_node(str(currentTab) + "/GridContainer/" + selectedItem["id"]).showInUse(false)
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/Cancel.hide()
	$BG/OptionsHolder/OptionsContainer/VBoxContainer/UseButton.show()
	$BG/OptionsHolder/ReUse.button_pressed = false

func _on_exit_button_pressed():
	self.hide()
	phoneMenu.show()


func _on_re_use_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if selectedItem["id"] not in Globals.inUseItems:
			_on_use_button_pressed()
		Globals.reUseItems.append(selectedItem["id"])
	else:
		#Top 10 worst lines of code ever
		if Globals.reUseItems.has(selectedItem["id"]):
			Globals.reUseItems.remove_at(
				Globals.reUseItems.find(selectedItem["id"]))
	

func _on_visibility_changed() -> void:
	if self.visible:
		#Checks to see if item exists
		
		if selectedItem and Globals.itemInventory[selectedItem["id"]] <= 0:
			hideEverything()
		
		for button in $"BG/TabBar/0/GridContainer".get_children():
			button.update() #Swag
