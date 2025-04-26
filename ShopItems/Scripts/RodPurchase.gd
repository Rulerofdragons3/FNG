extends Purchase
class_name RodPurchase

@export var rod:ItemRod

func purchase():
	if rod not in Globals.rods:
		Globals.rods.append(rod)
