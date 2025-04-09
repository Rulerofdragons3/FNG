extends ColorRect

@export var item:Item

signal showItemDesc(itemType:Item)

# Huzzah
func _on_pressed():
	if item.count > 0:
		showItemDesc.emit(item)

func setup():
	$Button.texture_normal = item.texture
	#Hides item count if item is non-consumable
	if not item.consumable:
		$Count.hide()
	
	update() #Resuing code lol
	
func update():
	$Count.text = "x" + str(item.count)
	$InUseIndicator.visible = (item in Globals.inUseItems) #Checks if item is being used	
	self.visible = item.count > 0

func showInUse(val:bool):
	$InUseIndicator.visible = val


func _on_button_focus_entered():
	self.color = Color8(225,225,225,self.color.a8)


func _on_button_focus_exited():
	self.color = Color8(0,0,0,self.color.a8)
