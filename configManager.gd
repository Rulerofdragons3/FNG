extends Node

var saveDir = "user://Player.configs"

var config = {
	"Music":100,
	"Waves":100,
	"SFX":100,
	"wallpaperPath":"",
	"StartMinigame":KEY_SPACE,
	"Note":"I'd reccomend not changing anything here, as I don't know what may happen as a result."
}

func updateCFG():
	#Creates/loads save file
	var CFGFile = FileAccess.open(saveDir,FileAccess.WRITE)
	CFGFile.store_string(JSON.stringify(config,"\t"))
	CFGFile.close() #For good measure

func loadCFG():
	if not FileAccess.file_exists(saveDir):
		updateCFG()
		return #Aborts essentially
	
	var fileDat = JSON.parse_string(FileAccess.get_file_as_string(saveDir))
	print(fileDat)
	for data in fileDat:
		if data in config:
			config[data] = fileDat[data]
	
	loadKeybinds()
	
func loadKeybinds():
	var actions = ["StartMinigame"]
	for action in actions:
		InputMap.action_erase_events(action)
		var key = InputEventKey.new()
		key.keycode = config[action]
		InputMap.action_add_event(
			action, 
			key
			)

