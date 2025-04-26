extends ColorRect

@export var purchase:Purchase
@export var upgradePath:String = ""

func _ready() -> void:
	$Title.text = "[url]" + purchase.title + "[/url]"
	$Price.text = "$" + str(purchase.price)
	$TextureRect.texture = purchase.icon

func _on_title_meta_clicked(_meta: Variant) -> void:
	self.find_parent("Results").loadPurchasePage(purchase, upgradePath)
