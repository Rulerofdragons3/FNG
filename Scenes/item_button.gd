extends ColorRect

@export var itemID:String = ""
var count:int = 0

signal showItemDesc(ID)

# Huzzah
func _on_pressed():
	if count > 0:
		showItemDesc.emit(itemID)

func setup():
	var data = JSON.parse_string(FileAccess.get_file_as_string(
		"res://Items/ItemDat/" + itemID + ".json"
	))
	if "texture" in data and data["texture"] != "":
		$Button.texture_normal = load("res://Assets/Items/" + data["texture"])
	#Hides item count if item is non-consumable
	if "consumable" in data and !data["consumable"]:
		$Count.hide()
	
	update() #Resuing code lol
	
func update():
	count = Globals.itemInventory[itemID]
	$Count.text = "x" + str(count)
	
	$InUseIndicator.visible = (itemID in Globals.inUseItems) #Checks if item is being used
	if count <= 0:
		self.hide()
		#self.modulate = Color8(200,200,200)
	else:
		self.show()
		#self.modulate = Color8(255,255,255)

func showInUse(val:bool):
	$InUseIndicator.visible = val


func _on_button_focus_entered():
	self.color = Color8(225,225,225,self.color.a8)


func _on_button_focus_exited():
	self.color = Color8(0,0,0,self.color.a8)
