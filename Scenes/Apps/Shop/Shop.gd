extends Control

@onready var moneyLabel = $"../Ui/MoneyLabel"
@onready var phoneMenu = $"../Ui/Phone"
@onready var websites = $"../Websites"

func refresh():
	var ads = $ScrollContainer/VBoxContainer/PanelContainer/Ads
	var adsAmt = ads.sprite_frames.get_frame_count("ads") - 1 
	ads.frame = randi_range(0,adsAmt)
	var isMaxed = true #Reused to determine what upgrades are maxed
	
	#Product control
	for upgrade in Globals.upgrades:
		#Gets parent node of the upgrade
		var upgradeParent = "ScrollContainer/VBoxContainer/"+str(upgrade)
		var upgradeDat
		for upgradeData in Globals.upgrades[upgrade]:
			upgradeDat = upgradeData
			if not upgradeDat["obtained"]:
				get_node(upgradeParent+"/Desc").text = upgradeDat["desc"]
				get_node(upgradeParent+"/Purchase/Price").text = "$" + str(upgradeDat["price"])
				isMaxed = false
				break #riff bum bum tiss badum badum tiss
		if isMaxed:
			get_node(upgradeParent+"/Desc").text = upgradeDat["desc"]
			get_node(upgradeParent+"/Purchase").disabled = true
			get_node(upgradeParent+"/Purchase/Price").text = "SOLD OUT!" 
		isMaxed = true

func _on_purchase_pressed(upgradeName):
	var toUpg = null
	var dataPos = 0
	#Finds the latest upgrade to buy
	for upgrade in Globals.upgrades[upgradeName]:
		if not upgrade["obtained"]:
			toUpg = upgrade
			break
		dataPos += 1
	#Actually buying
	if not toUpg:
		return
		
	elif toUpg["price"] <= Globals.money:
		Globals.money -= toUpg["price"]
		Globals.upgrades[upgradeName][dataPos]['obtained'] = true
		#Update money label
		moneyLabel.text = "$" + "%.2f" % Globals.money
		#le switch statement
		#Remember that upgradeNames are determined in the node tab
		match upgradeName:
			"baseMultiplierUpgrades":
				Globals.baseMultiplier += toUpg["increase"]
				
			"performanceMultiplierUpgrades":
				Globals.performanceMultiplier += toUpg["increase"]
			
			"cheapValueMultiplier":
				Globals.cheapValueMultiplier = toUpg["increase"]
			
			"locations":
				if toUpg["increase"] not in Globals.obtainedWorlds:
					Globals.obtainedWorlds.append(toUpg["increase"])
		
		Globals.saveGame()
		refresh()
	else:
		pass
		
func _on_exit_button_pressed():
	self.visible = false
	phoneMenu.visible = true
	
#Funny sites
func _on_go_to_site_pressed():
	var ad = $ScrollContainer/VBoxContainer/PanelContainer/Ads.frame
	websites.generateWebsite(ad)
	self.hide()
	websites.show()
		

func _on_visibility_changed(): #Resets when toggled
	if self.visible:
		$ScrollContainer.scroll_vertical = 0 
		refresh()
