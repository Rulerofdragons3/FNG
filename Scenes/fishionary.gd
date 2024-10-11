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
var currentFishID = ""

func createEntry(ID:String):
	var data:Dictionary = fishData[ID]
	
	var entry = fishContainer.instantiate()
	var icon = entry.get_node("Icon")
	var fishName = entry.get_node("Name")
	#Connecting button press to this script
	entry.ID = ID
	entry.connect("showFishcription",self.show_fishcription)
	
	#var frameData = null
	#if fishSprites: #Prevents errors
	#	frameData = fishSprites.sprite_frames.get_frame_texture("default",ID)
	
	#Checks if obtained or not
	icon.texture = load("res://Assets/Fish/" + data["texture"])
	if ID in Globals.obtainedFishIDs:
		fishName.text = data['name']
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


func show_fishcription(ID):
	currentFishID = ID
	$BG.visible = false
	$ScrollContainer.visible = false
	var fish:Dictionary = fishData[ID]
	var obtained = (ID in Globals.obtainedFishIDs)
	#Setting up description
	if obtained:
		$FiscriptionBG/Name.text = fish['name']
		$FiscriptionBG/Value.text = "Base Value:\n$" + "%.2f" % fish['value']
		$FiscriptionBG/Desc.text = fish['desc']
		if Globals.obtainedFishIDs[ID]["caughtShiny"] >= 1:
			$FiscriptionBG/ShowShiny.show()
	else:
		$FiscriptionBG/Name.text = "???" 
		$FiscriptionBG/Value.text = "Base Value:\n???"
		$FiscriptionBG/Desc.text = "???"
		
	$FiscriptionBG/Rarity.text = "Rarity:\n" + str(fish['rarity'])
	
	if true: 
		var texture = load("res://Assets/Fish/" + fish["texture"])
		$FiscriptionBG/Icon.texture = texture
		if !obtained:
			$FiscriptionBG/Icon.modulate = Color.BLACK
		else:
			$FiscriptionBG/Icon.modulate = Color.WHITE
	
	if "world" not in fish:
		$FiscriptionBG/Worlds.text = "Found in:\n" + worldData['ocean']['name']
	else:
		var worldList = "Found in:\n"
		var worldAmount = len(fish['world'])
		for i in range(worldAmount - 1):
			if fish['world'][i] in worldData:
				worldList += worldData[fish['world'][i]]['name'] + ", "
			else:
				worldList += fish['world'][i]
		#
		if fish['world'][worldAmount - 1] in worldData:
				worldList += worldData[fish['world'][worldAmount - 1]]['name']
		else:
			worldList += fish['world'][worldAmount - 1]
				
		
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
	print(currentFishID)
	var texture = load("res://Assets/Fish/" + Globals.fishData[currentFishID]["texture"])
	if not showingShiny:
		if "shinyOverride" in fishData[currentFishID]:
			$FiscriptionBG/Icon.texture = ShinyHandler.createShiny(
				texture.get_image(),
				fishData[currentFishID]["shinyOverride"]
				)
		else:
			$FiscriptionBG/Icon.texture = ShinyHandler.createShiny(texture.get_image())
		
		$FiscriptionBG/ShowShiny.texture_normal = load("res://Assets/Buttons/ShowShinyPressed.png")
		$FiscriptionBG/ShowShiny.texture_pressed = load("res://Assets/Buttons/ShowShiny.png")
		if "shinyDesc" in fishData[currentFishID]:
			$FiscriptionBG/Desc.text = fishData[currentFishID]['shinyDesc']
		else:
			$FiscriptionBG/Desc.text = fishData[currentFishID]['desc']
			
		$ShowShinySound.stop()
		$ShowShinySound.play()
	else:
		$FiscriptionBG/ShowShiny.texture_normal = load("res://Assets/Buttons/ShowShiny.png")
		$FiscriptionBG/ShowShiny.texture_pressed = load("res://Assets/Buttons/ShowShinyPressed.png")
		$FiscriptionBG/Icon.texture = texture
		$FiscriptionBG/Desc.text = fishData[currentFishID]['desc']
	showingShiny = not showingShiny #Inverts value
