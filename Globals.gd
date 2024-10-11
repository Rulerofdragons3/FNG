extends Node


var fishData:Dictionary = {}
var money:float = 0.00
var baseMultiplier = 1
var performanceMultiplier = 1
var cheapValueMultiplier = 0
var obtainedFishIDs:Dictionary = {}
#var obtainedShinies = []
var world = "ocean"
var obtainedWorlds = ['ocean']
var worldPool:Array = [] #Fish available in the selected world
var SECURITY_KEY = "493610325234" #Encryption pass to prevent save editing

#The long one
var upgrades = JSON.parse_string(FileAccess.get_file_as_string("res://upgrades.json"))

func createFishData():
	var fishDir = "res://FishDat/"
	for fishFile in DirAccess.get_files_at(fishDir):
		var fileDat:Dictionary = JSON.parse_string(FileAccess.get_file_as_string(fishDir + fishFile))
		var dat = {
			fileDat["id"] : fileDat
		}
		fishData.merge(dat)
	
	
func setWorldPool(worldName):
	world = worldName
	worldPool = []
	#Grabs all fish for the world and adds them to the pool
	for fish in fishData:
		#print(fishData[fish])	
		if (fishData[fish].has('world')) and (fishData[fish]['world'].has(world)):
			#print("Added ", fishData[fish]['name'], " to world: ", worldName)
			worldPool.append(fish)
		elif world == 'ocean' and ("world" not in fishData[fish]): #Just so i don't have to update everything
			#print("Defaulting to ocean for: ", fishData[fish]['name'])
			worldPool.append(fish)

var saveDir = "user://Player.save"

func updateLegacySaveData():
	print("Started")
	var saveFile = FileAccess.open_encrypted_with_pass(saveDir,FileAccess.READ,SECURITY_KEY)
	print(FileAccess.get_open_error())
	if saveFile:
		saveFile.close()
		return false
	
	saveFile = FileAccess.open(saveDir,FileAccess.READ)
	var saveData = saveFile.get_var()
	print("SaveData")
	"""
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
	"""
	print("FishData")
	var ogFishData = JSON.parse_string(FileAccess.get_file_as_string("res://FishDat.json"))
	if saveData['obtainedFishIDs']:
		var newData = {}
		for fish in saveData['obtainedFishIDs']:
			var hasShiny = 0
			if fish in saveData['obtainedShinies']:
				hasShiny = 1
			#The line
			var fishID:String = ogFishData[fish]["name"].replace(
				" ","_").replace("'","").replace(".","").to_lower()
			newData.merge(
				{
					fishID:{
						"caught":1,
						"caughtShiny":hasShiny}
				})
		obtainedFishIDs = newData
		print(saveData)
	print("Done!")
	return true

#Saves are stored in 
#"C:\Users\[your name]\AppData\Roaming\Godot\app_userdata\FNG" 
func saveGame():
	#Creates/loads save file
	var saveFile = FileAccess.open_encrypted_with_pass(saveDir,FileAccess.WRITE,SECURITY_KEY)
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
		"obtainedWorlds":obtainedWorlds
	}
	
	saveFile.store_var(saveData,true)
	saveFile.close() #For good measure

func loadSave():
	if not FileAccess.file_exists(saveDir):
		saveGame()
		return #Aborts essentially
	var isLegacy = updateLegacySaveData()
	
	#Dont even ask about these lines
	var saveData
	if isLegacy:
		var saveFile = FileAccess.open(saveDir,FileAccess.READ)
		saveData = saveFile.get_var()
		saveFile.close()
	else:
		var saveFile = FileAccess.open_encrypted_with_pass(saveDir,FileAccess.READ,SECURITY_KEY)
		saveData = saveFile.get_var()
		saveFile.close()
	
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
	if !isLegacy and saveData['obtainedFishIDs']:
		obtainedFishIDs = saveData['obtainedFishIDs']
	if 'world' in saveData:
		world = saveData['world']
	if 'obtainedWorlds' in saveData:
		obtainedWorlds = saveData['obtainedWorlds']
		
	#I'm glad i rewrote this save system this is much easier :3
	
