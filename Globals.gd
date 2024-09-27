extends Node

var fishFile = "res://FishDat.json"
var fishData = JSON.parse_string(
	FileAccess.get_file_as_string(fishFile)
)
var money:float = 0.00
var baseMultiplier = 1
var performanceMultiplier = 1
var cheapValueMultiplier = 0
var obtainedFishIDs = []
var obtainedShinies = []
var world = "ocean"
var obtainedWorlds = ['ocean','nightOcean','redSea','dreadSea','junkPatch']
var worldPool = [] #Fish available in the selected world

#The long one
var upgrades = JSON.parse_string(FileAccess.get_file_as_string("res://upgrades.json"))

func setWorldPool(worldName):
	world = worldName
	worldPool = []
	#Grabs all fish for the world and adds them to the pool
	for fish in fishData:
		if ("world" in fish) and (worldName in fish['world']):
			#print("Added ", fish['name'], " to world", worldName)
			worldPool.append(fish)
		elif world == 'ocean' and ("world" not in fish): #Just so i don't have to update everything
			#print("Defaulting to ocean for: ", fish['name'])
			worldPool.append(fish)

var saveDir = "user://Player.save"

#Saves are stored in 
#"C:\Users\[your name]\AppData\Roaming\Godot\app_userdata\FNG" 
func saveGame():
	#Creates/loads save file
	var saveFile = FileAccess.open(saveDir,FileAccess.WRITE)
	var upgSave = []
	for upgrade in upgrades.values():
		var obtainedUpgrades = []
		for subUpgrade in upgrade:
			obtainedUpgrades.append(subUpgrade['obtained'])
		upgSave.append(obtainedUpgrades)
	
	var saveData = {
		"money":money,
		"baseMultiplier":baseMultiplier,
		"performanceMultiplier":performanceMultiplier,
		"cheapValueMultiplier":cheapValueMultiplier,
		"upgrades":upgSave,
		"obtainedFishIDs":obtainedFishIDs,
		"world":world,
		"obtainedWorlds":obtainedWorlds,
		"obtainedShinies":obtainedShinies
	}
	
	saveFile.store_var(saveData)
	saveFile.close() #For good measure

func loadSave():
	if not FileAccess.file_exists(saveDir):
		saveGame()
		return #Aborts essentially
	
	var saveFile = FileAccess.open(saveDir,FileAccess.READ)
	var saveData = saveFile.get_var()
	
	#Sets values if any save value is present
	if 'money' in saveData: #I wish there was an easier way
		money = saveData['money']
	if 'baseMultiplier' in saveData:
		baseMultiplier = saveData['baseMultiplier']
	if 'performanceMultiplier' in saveData:
		performanceMultiplier = saveData['performanceMultiplier']
	if 'cheapValueMultiplier' in saveData:
		cheapValueMultiplier = saveData['cheapValueMultiplier']
	if 'upgrades' in saveData:
		#This next line loads the array that saves the states of the upgrades
		var upgSave = saveData['upgrades']
		var lp = [0,0] #LoadProgress
		for upgrade in upgrades.values():
			for subUpgrade in upgrade:
				if lp[0] <= len(saveData['upgrades']) - 1:
					subUpgrade['obtained'] = upgSave[lp[0]][lp[1]]
				else:
					subUpgrade['obtained'] = false
				lp[1] += 1
			lp[0] += 1
			lp[1] = 0 
	if saveData['obtainedFishIDs']:
		obtainedFishIDs = saveData['obtainedFishIDs']
	if 'world' in saveData:
		world = saveData['world']
	if 'obtainedWorlds' in saveData:
		#obtainedWorlds = saveData['obtainedWorlds']
		pass
	if 'obtainedShinies' in saveData:
		obtainedShinies = saveData['obtainedShinies']
	#I'm glad i rewrote this save system this is much easier :3
	saveFile.close()
