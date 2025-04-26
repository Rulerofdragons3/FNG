extends Purchase
class_name ItemPurchase

@export var item:Item
@export var quantity:int = 1

func purchase():
	ItemManager.giveItemRes(item, quantity)
