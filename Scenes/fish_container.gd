extends Button

@export var ID:String

signal showFishcription(ID)

#@onready var fishionary = $"../Fishionary"

# Huzzah
func _on_pressed():
	#print("Button " + str(ID) + " pressed!")
	showFishcription.emit(ID)

func update():
	$Icon.modulate = Color.WHITE
	$Name.text = Globals.fishData[ID]["name"]
