extends Purchase
class_name CheapValueMultiplierUpgrade

@export var increaseTo:float = 1
func purchase():
	Globals.cheapValueMultiplier = increaseTo
