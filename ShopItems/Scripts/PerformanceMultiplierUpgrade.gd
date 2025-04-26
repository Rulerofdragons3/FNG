extends Purchase
class_name PerformanceMultiplierUpgrade

@export var increaseTo:float = 1
func purchase():
	Globals.performanceMultiplier = increaseTo
