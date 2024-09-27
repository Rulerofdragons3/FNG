extends Button

@export var ID = 0

signal showFishcription(ID)

#@onready var fishionary = $"../Fishionary"

# Huzzah
func _on_pressed():
	#print("Button " + str(ID) + " pressed!")
	showFishcription.emit(ID)
