extends Node

const SAVE_PATH = "user://save.res"

func _ready() -> void:
	LimboConsole.register_command(save_game,"save","Saves the game.")
	LimboConsole.register_command(load_game,"load","Loads save data.")

func save_game():
	var save:Save = Save.new()
	save.money = Globals.money
	save.upgrades = Globals.upgrades
	save.obtainedFishIDs = Globals.obtainedFishIDs
	save.world = Globals.world
	save.obtainedWorlds = Globals.obtainedWorlds
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
	Globals.upgrades = save.upgrades
	Globals.obtainedFishIDs = save.obtainedFishIDs
	Globals.world = save.world
	Globals.obtainedWorlds = save.obtainedWorlds
	#Weird loop that will magically
	for saveItem:Dictionary in save.itemInventory:
		var item:Item = saveItem["Item"]
		for property:String in saveItem["Properties"]:
			item.set(property,saveItem["Properties"][property])
		Globals.itemInventory.append(item)
