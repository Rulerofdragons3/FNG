extends Node

enum Events {OnFished}

func _ready() -> void:
	var itemDirs = get_dirs_recursive("res://Items/ItemData/")
	print(itemDirs)
	LimboConsole.register_command(giveItemThruCommand,"item")
	LimboConsole.add_argument_autocomplete_source("item",1, func():
		return itemDirs #yeah
		)

func get_dirs_recursive(PATH) -> Array:
	var subDirs = []
	var dir = DirAccess.open(PATH)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			subDirs.append_array(
				get_dirs_recursive(dir.get_current_dir() + "/"+ file_name +"/")
				)
			return subDirs
		else:
			subDirs.append(
				dir.get_current_dir().replace("res://Items/ItemData/","") +
				"/" + file_name
				)
		file_name = dir.get_next()
	return subDirs

func giveItemThruCommand(subDir:String, count:int = 1):
	var success = giveItem(subDir, count)
	if success:
		LimboConsole.print_line("Successfully gave item!")
	else:
		LimboConsole.error("Item \"" + subDir + "\" does not exist!")

## subDir: Directory to item starting at res://Items/ItemData/
## Gives the player an item
func giveItem(subDir:String, count:int = 1) -> bool:
	if not FileAccess.file_exists("res://Items/ItemData/" + subDir):
		push_error("Item \"" + subDir + "\" does not exist!")
		return false
		
	var item:Item = load("res://Items/ItemData/" + subDir)
	if item in Globals.itemInventory:
		item.incrementCount(count)
	else:
		item.count = count
		Globals.itemInventory.append(item)
	return true
	
## subDir: Directory to item starting at res://Items/ItemData/
## Gives the player an item
func giveItemRes(item:Item, count:int = 1):
	if item in Globals.itemInventory:
		item.incrementCount(count)
	else:
		item.count = count
		Globals.itemInventory.append(item)

## subDir: Directory to item starting at res://Items/ItemData/
## Depletes an item
func removeItem(subDir:String, count:int = 1) -> bool:
	if not FileAccess.file_exists("res://Items/ItemData/" + subDir):
		push_error("Item \"" + subDir + "\" does not exist!")
		return false
	
	var item:Item = load("res://Items/ItemData/" + subDir)
	if item in Globals.itemInventory:
		item.depleteCount(count)
	return true

func triggerItems(event:Events):
	var functionName:String = Events.find_key(event)
	for item:Item in Globals.inUseItems:
		if item.has_method(functionName):
			item.call(functionName)
		item.depleteCount(1)
