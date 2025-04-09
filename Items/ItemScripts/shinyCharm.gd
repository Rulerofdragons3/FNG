extends Item
class_name ShinyCharm

@export var shinyOddsIncrease:int = 0


func equipped():
	Globals.shinyOdds += shinyOddsIncrease
	print(self.displayName + " equipped. Shiny Odds are now at " + str(Globals.shinyOdds) + "%")
	
#For for when the item is depleted, or it is finished being used
func unequipped():
	Globals.shinyOdds -= shinyOddsIncrease
	print(self.displayName + " depleted. Shiny Odds are now at " + str(Globals.shinyOdds) + "%")

func onFished():
	pass
	#ItemHandler
	
