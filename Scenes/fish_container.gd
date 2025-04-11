extends Button

@export var fish:Fish

signal showFishcription(ID)

# Huzzah
func _on_pressed():
	showFishcription.emit(fish)

func update():
	$Icon.modulate = Color.WHITE
	$Name.text = fish.name
