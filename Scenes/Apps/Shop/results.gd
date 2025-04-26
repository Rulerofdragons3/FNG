extends ScrollContainer

signal finishedLoading
enum Categories {Upgrades, Items, Rods, Cosmetics}
@onready var websites = $"../../Websites"
var productScene:PackedScene = preload("res://Scenes/Apps/Shop/Product.scn")
var reloadTo:Categories = Categories.Upgrades
var dailySeed = 0

func _ready():
	setDailySeed()
	setAd()

func dailyWeightedChoice(pool:Dictionary, rand:RandomNumberGenerator) -> String:
	var maximum:int = 0
	for choice in pool:
		maximum += pool[choice]
	var randNum = rand.randi_range(1, maximum)
	for choice:String in pool: 
		if randNum < pool[choice]:
			return choice
		randNum -= pool[choice]
	return pool.keys()[0]

## Loads daily item shop
func loadItemPurchases():
	reloadTo = Categories.Items
	var items:Array = load("res://ShopItems/ShopPool.json").data
	var rand = RandomNumberGenerator.new()
	rand.seed = dailySeed
	var i:int = 0
	for slotChoices:Dictionary in items:
		var dir:String = dailyWeightedChoice(slotChoices, rand)
		var purchase:Purchase = load(dir)
		var product = productScene.instantiate()
		product.purchase = purchase
		product.name = str(i)
		$VBoxContainer.add_child(product)
		i += 1
	finishedLoading.emit()
	
## Loads available upgrades
func loadUpgradePurchases():
	reloadTo = Categories.Upgrades
	const PATH = "res://ShopItems/Upgrades/Upgrade Paths/"
	var upgradePaths = DirAccess.get_files_at(PATH)
	for file in upgradePaths:
		var upgradePath:UpgradePath = load(PATH + file)
		var purchase:Purchase = upgradePath.getNextUpgrade()
		if purchase:
			var product = productScene.instantiate()
			product.purchase = purchase
			product.upgradePath = upgradePath.ID
			$VBoxContainer.add_child(product)
	finishedLoading.emit()

## Loads available upgrades
func loadRodPurchases():
	reloadTo = Categories.Rods
	const PATH = "res://ShopItems/RodPurchases/"
	var rodPaths = DirAccess.get_files_at(PATH)
	for file in rodPaths:
		var purchase:RodPurchase = load(PATH + file)
		if purchase and (purchase.rod not in Globals.rods):
			var product = productScene.instantiate()
			product.purchase = purchase
			$VBoxContainer.add_child(product)
	finishedLoading.emit()


## Loads the purchase page
func loadPurchasePage(purchase:Purchase, upgradePath:String = ""):
	self.hide()
	%PurchasePage/ProductImage.texture = purchase.icon
	%PurchasePage/StarsBG/Stars.size = Vector2(8 * purchase.stars,8)
	%PurchasePage/Title.text = purchase.title
	%PurchasePage/Price.text = "$" + str("%0.2f" % purchase.price)
	%PurchasePage/Desc.text = purchase.description
	%PurchasePage.purchase = purchase
	%PurchasePage.upgradePath = upgradePath
	%PurchasePage.show()

## Resets the page's contents
func resetPage():
	for i in range(2, $VBoxContainer.get_child_count()):
		$VBoxContainer.get_child(i).queue_free()

## "Refreshes" the page
func refreshPage():
	resetPage()
	match reloadTo:
		Categories.Upgrades:
			self.loadUpgradePurchases()
		Categories.Items:
			self.loadItemPurchases()
		Categories.Rods:
			self.loadRodPurchases()

func _on_back_button_pressed() -> void:
	self.hide()
	%MainPage.show()
	resetPage()

func setDailySeed():
	var today = Time.get_date_string_from_system()
	dailySeed = int(today.replace(" ",""))

func setAd():
	var ads = $VBoxContainer/AdContainer/Ads
	var adsAmt = ads.sprite_frames.get_frame_count("ads") - 1 
	ads.frame = randi_range(0,adsAmt)

func _on_visibility_changed() -> void:
	setDailySeed()
	setAd()
	self.get_parent().get_node("BackButton").visible = self.visible

func _on_go_to_site_pressed():
	var ad = $VBoxContainer/AdContainer/Ads.frame
	websites.generateWebsite(ad)
	self.get_parent().hide()
	websites.show()
