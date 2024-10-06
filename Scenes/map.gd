extends ColorRect

@onready var phoneMenu = $"../Ui/Phone"
@onready var menuButton = $"../Ui/MenuButton"
@onready var Fade = $"../Ui/Fade"
@onready var BG = $"../Background"
@onready var bar = $"../Bar"
@onready var musicPlayer = $"../Background/Music" 
@onready var musicController = $"../Background"

var worldButton = preload("res://Scenes/world_button.tscn")
var worldConfigFile = "res://worldConfigs.json"
var worldConfigs = JSON.parse_string(
	FileAccess.get_file_as_string(worldConfigFile)
)
var selectedWorld = ""

func _ready():
	selectedWorld = Globals.world
	var globeOrientation = worldConfigs[selectedWorld]['globeOrientation']
	$SubViewport/Globe.rotation = Vector3(
			deg_to_rad(globeOrientation[0]),
			deg_to_rad(globeOrientation[1]),
			deg_to_rad(globeOrientation[2])
		)
	$SubViewport/Ship.reparent($SubViewport/Globe,true)
	
	if selectedWorld == "":
		selectedWorld = 'ocean'
	var BGTexture = "res://Assets/Backgrounds/" + worldConfigs[selectedWorld]['background']
	BG.texture = load(BGTexture)
	#Save Game
	Globals.setWorldPool(selectedWorld)
	
	
func createEntry(worldName:String):
	var entry = worldButton.instantiate()
	var buttonName = entry.get_node("Name")
	#Connecting button press to this script
	entry.worldName = worldName
	entry.connect("selectWorld",self.selectWorld)
	
	#Checks if obtained or not
	if worldName in Globals.obtainedWorlds:
		buttonName.text = worldConfigs[worldName]['name']
		
	else:
		buttonName.text = "???"
		entry.disabled = true
	
	$ScrollContainer/WorldList.add_child(entry)
	
func selectWorld(worldName):
	selectedWorld = worldName
	$DescBox/Name.text = worldConfigs[worldName]['name']
	$DescBox/Desc.text = worldConfigs[worldName]['desc']
	var globeTween = create_tween()
	var globeOrientation = worldConfigs[worldName]['globeOrientation']
	globeTween.tween_property(
		$SubViewport/Globe,
		"rotation",
		Vector3(
			deg_to_rad(globeOrientation[0]),
			deg_to_rad(globeOrientation[1]),
			deg_to_rad(globeOrientation[2])
		),
		1
	)
	globeTween.set_ease(Tween.EASE_IN)
	globeTween.play()

func _process(_delta):
	if self.visible:
		var globeTexture = $SubViewport.get_viewport().get_texture()
		$GlobeBG/GlobeDisplay.texture = globeTexture

func _on_visibility_changed():
	if visible == true:
		for child in $ScrollContainer/WorldList.get_children():
			$ScrollContainer/WorldList.remove_child(child)
		selectWorld(Globals.world)
		#Should probably rewrite this lol
		for i in range(len(worldConfigs) + 1):
			for world in worldConfigs:
				if worldConfigs[world]["order"] == i:
					createEntry(world)

func _on_exit_button_pressed():
	hide()
	self.visible = false
	phoneMenu.visible = true
	
func _on_travel_button_pressed():
	Fade.modulate.a = 0
	Fade.show()
	var fade = create_tween()
	fade.tween_property(Fade,"modulate",Color8(255,255,255,255),0.5)
	fade.tween_property(musicPlayer,"volume_db",-20,0.5)
	fade.play()
	await fade.finished
	#Change World
	if selectedWorld == "":
		selectedWorld = 'ocean'
	var BGTexture = "res://Assets/Backgrounds/" + worldConfigs[selectedWorld]['background']
	BG.texture = load(BGTexture)
	#Music
	musicPlayer.stop() #Stops world music
	musicPlayer.volume_db = 0
	#Save Game
	Globals.setWorldPool(selectedWorld)
	Globals.saveGame()
	#Reset Music
	musicController.resetMusic()
	#Reset Ship Location
	$SubViewport/Globe/Ship.reparent($SubViewport,true)
	$SubViewport/Ship.position = Vector3(0,0,1)
	$SubViewport/Ship.rotation = Vector3(0,0,0)
	$SubViewport/Ship.reparent($SubViewport/Globe,true)
	#Wait a second	
	$Timer.start()
	await $Timer.timeout
	#Hide self
	self.hide()
	#Reset and play tween
	fade = create_tween()
	fade.tween_property(Fade,"modulate",Color8(255,255,255,0),0.5)
	fade.play()
	await fade.finished
	#Reset to default menu
	Fade.hide()
	menuButton.visible = true
	bar.canFish = true
