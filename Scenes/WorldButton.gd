extends Button

@export var worldName = "ocean"

signal selectWorld(worldName)

#@onready var fishionary = $"../Fishionary"

# Huzzah
func _on_pressed():
	#print("Button " + str(ID) + " pressed!")
	selectWorld.emit(worldName)
