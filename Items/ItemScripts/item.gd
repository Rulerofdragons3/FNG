extends Resource
class_name Item

@export var texture:Texture
@export var stackable:bool
var count

func depleteCount(amount:int = 1):
	count -= amount
	return count

func incrementCount(amount:int = 1):
	if stackable:
		count += 1
