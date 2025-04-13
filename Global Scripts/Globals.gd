extends Node

var fishData:Dictionary = {}
var money:float = 0.00
var baseMultiplier = 1
var performanceMultiplier = 1
var cheapValueMultiplier = 0
var obtainedFishIDs:Dictionary = {}
var world = "ocean"
var obtainedWorlds = ['ocean']
var worldPool:Array[Fish] = [] #Fish available in the selected world
var shinyOdds = 0.0005
var itemInventory:Array[Item] = []

#Non - saved
var inUseItems:Array[Item] = []
var reUseItems:Array[Item] = []

var SECURITY_KEY = "493610325234" #Encryption pass to prevent save editing
#The long one
var upgrades = JSON.parse_string(FileAccess.get_file_as_string("res://upgrades.json"))

func _ready():
	LimboConsole.register_command(_fish_command,"fish","unlocks fish")

func _fish_command(fishDir):
	var path = "res://FishData/Resources/" + fishDir
	if path not in Globals.obtainedFishIDs:
		Globals.obtainedFishIDs.merge({path:{"caught":0,"caughtShiny":1}})
	else:
		Globals.obtainedFishIDs[path]["caught"] = 0
		Globals.obtainedFishIDs[path]["caughtShiny"] = 1

func get_dirs_recursive(PATH) -> Array:
	var subDirs = []
	var dir = DirAccess.open(PATH)
	for file in dir.get_files():
		subDirs.append(PATH + "/" + file)
	for directory in dir.get_directories():
		subDirs.append_array(get_dirs_recursive(PATH + directory))	
	return subDirs

func createFishData():
	var fishDataDir = "res://FishData/Resources/"
	var fishDirs:PackedStringArray = []
	for fishDir:String in get_dirs_recursive(fishDataDir):
		var dat = {
			fishDir.get_file() : fishDir
		}
		fishData.merge(dat)
		fishDirs.append(fishDir.replace(fishDataDir, ""))
	LimboConsole.add_argument_autocomplete_source("fish",1,func():
		return fishDirs
		)
	
func setWorldPool(worldName):
	self.world = worldName
	self.worldPool = []
	#Grabs all fish for the world and adds them to the pool
	# TODO: Fix O(N) execution time pls
	for fishFile in fishData:
		var fish:Fish = load(fishData[fishFile])
		if world in fish.worlds:
			self.worldPool.append(fish)
