extends Node

var fishData:Dictionary = {}
var money:float = 0.00
var baseMultiplier = 1
var performanceMultiplier = 1
var cheapValueMultiplier = 0
var obtainedFishIDs:Dictionary = {}
var world = "ocean"
var obtainedWorlds = ['ocean']
var worldPool:Array = [] #Fish available in the selected world
var shinyOdds = 0.0005
var itemInventory:Array[Item] = []

#Non - saved
var inUseItems:Array[Item] = []
var reUseItems:Array[Item] = []

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
