extends Control

#VARIABLES
#Yes i am just grabbing them from the catch screen
#@onready var fishSprites = $"../FishSprites"
#For hiding things
@onready var phoneMenu = $"../Ui/Phone"

var fishContainer = preload("res://Scenes/fish_container.tscn")
var fishData = Globals.fishData
var worldConfigFile = "res://worldConfigs.json"
var worldData = JSON.parse_string(
	FileAccess.get_file_as_string(worldConfigFile)
)
var showingShiny = false
var currentFish:Fish

func createEntry(ID:String):
	var fish:Fish = load(fishData[ID])
	
	var entry = fishContainer.instantiate()
	var icon = entry.get_node("Icon")
	var fishName = entry.get_node("Name")
	#Connecting button press to this script
	entry.fish = fish
	entry.connect("showFishcription",self.show_fishcription)
	
	#Checks if obtained or not
	icon.texture = fish.texture
	if fish.resource_path in Globals.obtainedFishIDs:
		fishName.text = fish.name
	else:
		fishName.text = "???"
		icon.modulate = Color.BLACK
	
	$ScrollContainer/FishList.add_child(entry)
	
func createEntries():
	for fish in fishData:
		createEntry(fish)

func _on_exit_button_pressed():
	self.visible = false
	phoneMenu.visible = true
	showingShiny = false


func _on_visibility_changed():
	#"Just update the values!" No i dont wanna write another function
	for child in $ScrollContainer/FishList.get_children():
		$ScrollContainer/FishList.remove_child(child)
	createEntries()


func show_fishcription(fish:Fish):
	$BG.visible = false
	$ScrollContainer.visible = false
	currentFish = fish
	var ID = fish.resource_path
	var obtained = (ID in Globals.obtainedFishIDs)
	#Setting up description
	if obtained:
		$FiscriptionBG/Name.text = fish.name
		$FiscriptionBG/Value.text = "Base Value:\n$" + "%.2f" % fish.value
		$FiscriptionBG/Caught.text =  "Caught:\n" + str(
			Globals.obtainedFishIDs[ID]["caught"])
		$FiscriptionBG/Desc.text = fish.description
		$FiscriptionBG/Icon.get_material().set_shader_parameter("mode", 6)
		if Globals.obtainedFishIDs[ID]["caughtShiny"] >= 1:
			$FiscriptionBG/ShowShiny.show()
	else:
		$FiscriptionBG/Name.text = "???" 
		$FiscriptionBG/Value.text = "Base Value:\n???"
		$FiscriptionBG/Desc.text = "???"
		$FiscriptionBG/Icon.modulate = Color.BLACK
		
	$FiscriptionBG/Rarity.text = "Rarity:\n" + str(fish.rarity)
	$FiscriptionBG/Icon.texture = fish.texture
	$FiscriptionBG/HiddenIcon.texture = fish.texture
	$FiscriptionBG/Icon.visible = obtained
	$FiscriptionBG/HiddenIcon.visible = !obtained
	
	var worldList = "Found in:\n"
	var worldAmount = len(fish.worlds)
	for i in range(worldAmount - 1):
		if fish.worlds[i] in worldData:
			worldList += worldData[fish.worlds[i]]['name'] + ", "
		else:
			worldList += fish.worlds[i]
	#
	if fish.worlds[worldAmount - 1] in worldData:
			worldList += worldData[fish.worlds[worldAmount - 1]]['name']
	else:
		worldList += fish.worlds[worldAmount - 1]
			
	
	$FiscriptionBG/Worlds.text = worldList
	$FiscriptionBG.visible = true


func _on_back_button_pressed():
	$BG.visible = true
	$ScrollContainer.visible = true
	$FiscriptionBG.visible = false
	$FiscriptionBG/ShowShiny.hide()
	showingShiny = false
	$FiscriptionBG/ShowShiny.texture_normal = load("res://Assets/Buttons/ShowShiny.png")
	$FiscriptionBG/ShowShiny.texture_pressed = load("res://Assets/Buttons/ShowShinyPressed.png")


func _on_show_shiny_pressed():
	#Toggles Shiny
	var fishIcon = $FiscriptionBG/Icon
	if not showingShiny:
		$FiscriptionBG/ShowShiny.texture_normal = load("res://Assets/Buttons/ShowShinyPressed.png")
		$FiscriptionBG/ShowShiny.texture_pressed = load("res://Assets/Buttons/ShowShiny.png")
		# Actual Shiny Application
		ShinyHandler.createShiny(fishIcon, currentFish)
		$FiscriptionBG/Desc.text = currentFish.shinyDescription if currentFish.shinyDescription != "" else currentFish.description
		$FiscriptionBG/Caught.text = "Caught:\n" + str(
				Globals.obtainedFishIDs[currentFish.resource_path]["caughtShiny"])
			
		$ShowShinySound.stop()
		$ShowShinySound.play()
	else:
		match currentFish.shinyOverride:
			4:
				fishIcon.modulate = Color.WHITE
			5:
				fishIcon.texture = currentFish.texture
			_:
				fishIcon.get_material().set_shader_parameter("mode", 6)
		
		$FiscriptionBG/ShowShiny.texture_normal = load("res://Assets/Buttons/ShowShiny.png")
		$FiscriptionBG/ShowShiny.texture_pressed = load("res://Assets/Buttons/ShowShinyPressed.png")
		$FiscriptionBG/Caught.text =  "Caught:\n" + str(
			Globals.obtainedFishIDs[currentFish.resource_path]["caught"]
		)
		$FiscriptionBG/Desc.text = currentFish.description
	showingShiny = not showingShiny #Inverts value
