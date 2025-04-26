extends Node

const SAVE_PATH = "user://save.tres"

func _ready() -> void:
	LimboConsole.register_command(save_game,"save","Saves the game.")
	LimboConsole.register_command(load_game,"load","Loads save data.")

func save_game():
	var save:Save = Save.new()
	save.version = 1
	save.money = Globals.money
	save.upgrades = Globals.upgrades
	save.obtainedFishIDs = Globals.obtainedFishIDs
	save.world = Globals.world
	save.obtainedWorlds = Globals.obtainedWorlds
	save.currentRod = Globals.currentRod
	save.rods = Globals.rods
	for item:Item in Globals.itemInventory:
		save.itemInventory.append({
			"Item":item,
			"Properties":{
				"count":item.count
			}
		}) 
	ResourceSaver.save(save,SAVE_PATH)

func load_game():
	if not ResourceLoader.exists(SAVE_PATH):
		save_game()
		return
	var save:Save = load(SAVE_PATH)
	Globals.money = save.money
	Globals.obtainedFishIDs = save.obtainedFishIDs
	Globals.world = save.world
	Globals.obtainedWorlds = save.obtainedWorlds
	Globals.rods = save.rods
	Globals.currentRod = save.currentRod
	Globals.upgrades = save.upgrades
	for entry in Globals.upgrades:
		if (entry == "WorldUpgrades"):
			continue
		var upgrade:Purchase = Globals.upgrades[entry]
		if upgrade:
			upgrade.purchase()
		
	#Weird loop that will magically load items
	for saveItem:Dictionary in save.itemInventory:
		var item:Item = saveItem["Item"]
		for property:String in saveItem["Properties"]:
			item.set(property,saveItem["Properties"][property])
		Globals.itemInventory.append(item)
	
