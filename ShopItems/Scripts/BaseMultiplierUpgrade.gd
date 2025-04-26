extends Purchase
class_name BaseMultiplierUpgrade

@export var increaseTo:int = 1
func purchase():
	Globals.baseMultiplier = increaseTo
