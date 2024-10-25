extends Node

#Equipped
static func equipped(data):
	var amount = data["bonus"]
	Globals.shinyOdds += amount
	print(data["id"] + " equipped. Shiny Odds are now at " + str(Globals.shinyOdds) + "%")
	
#For for when the item is depleted, or it is finished being used
static func unequipped(data):
	var amount = data["bonus"]
	Globals.shinyOdds -= amount
	print(data["id"] + " depleted. Shiny Odds are now at " + str(Globals.shinyOdds) + "%")

static func onFished(data):
	Globals.depleteItem(data)
	
