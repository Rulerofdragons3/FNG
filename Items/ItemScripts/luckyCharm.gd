extends Item
class_name LuckyCharm

@export var luckIncrease:int = 0

func equipped():
	Globals.baseMultiplier += luckIncrease

#For for when the item is depleted, or it is finished being used
func unequipped():
	Globals.shinyOdds -= luckIncrease

func onFished():
	pass
	#ItemHandler	
