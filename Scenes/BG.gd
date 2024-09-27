extends TextureRect

var worldConfigFile = "res://worldConfigs.json"
var worldConfigs = JSON.parse_string(
	FileAccess.get_file_as_string(worldConfigFile)
)
var playlistIndex = 0
var playlist

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.loadSave() #Yes this is where I load the save data
	ConfigManager.loadCFG()
	$Waves.play()
	$Timer.wait_time = randi_range(60,300)
	resetMusic()

func resetMusic():
	$Timer.stop()
	if "playlist" not in worldConfigs[Globals.world]:
		return
	playlist = worldConfigs[Globals.world]["playlist"]
	playlistIndex = randi_range(0,len(playlist) - 1)
	$Timer.start()
	
func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var music = AudioStreamMP3.new()
	music.data = file.get_buffer(file.get_length())
	return music

func _on_timer_timeout():
	if playlistIndex >= len(worldConfigs[Globals.world]["playlist"]) - 1:
		playlistIndex = 0
	else:
		playlistIndex += 1
		
	var stream = load_mp3(
		"res://Assets/Sounds/Music/" + playlist[playlistIndex]
		)
	$Music.stream = stream
	$Music.play()
	await $Music.finished
	#Restart Timer	
	$Timer.wait_time = randi_range(60,300)
	$Timer.start()


func _physics_process(delta):
	$Path/MovingStuff.progress += 0.5 * delta

