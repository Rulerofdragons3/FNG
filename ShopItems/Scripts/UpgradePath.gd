extends Resource
class_name UpgradePath

@export var ID:String = "Upgrade"
@export var upgrades:Array[Purchase] = []

func getNextUpgrade() -> Purchase:
	#for u in upgrades:
	#	print(u.title)
	if ID in Globals.upgrades:
		if Globals.upgrades[ID]: #Checks if the player has the first upgrade
			var upgradeIndex = upgrades.find(Globals.upgrades[ID])
			if upgradeIndex >= len(upgrades) - 1: #End of path
				return null
			#print(upgradeIndex, " ",upgrades[upgradeIndex].title)
			return upgrades[upgradeIndex + 1] #Returns next upgrade
		# Else get the first upgrade
		return upgrades[0]
	else: #Adds upgrade path and returns the first upgrade
		Globals.upgrades.merge({ID : null})
		return upgrades[0]
