extends ColorRect

@export var rod:ItemRod

signal showItemDesc(itemType:ItemRod)

# Huzzah
func _on_pressed():
	showItemDesc.emit(rod)

func setup():
	$Button.texture_normal = rod.texture
	update() #Resuing code lol
	
func update():
	$InUseIndicator.visible = (Globals.currentRod == rod) #Checks if item is being used	

func showInUse(val:bool):
	$InUseIndicator.visible = val

func _on_button_focus_entered():
	self.color = Color8(225,225,225,self.color.a8)


func _on_button_focus_exited():
	self.color = Color8(0,0,0,self.color.a8)
