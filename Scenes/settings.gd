extends Control

#For hiding things
@onready var phoneMenu = $"../Ui/Phone"

func _ready():
	$ScrollContainer/SettingList/MusicVolSlider.value = ConfigManager.config["Music"]
	$ScrollContainer/SettingList/WaveVolSlider.value = ConfigManager.config["Waves"]
	$ScrollContainer/SettingList/SFXVolSlider.value = ConfigManager.config["SFX"]
	
	_on_vol_slider_changed(ConfigManager.config["Music"],"Music")
	_on_vol_slider_changed(ConfigManager.config["Waves"],"Waves")
	_on_vol_slider_changed(ConfigManager.config["SFX"],"SFX")
	
	#Update Preview
	if ConfigManager.config["wallpaperPath"] != "":
		changeWallpaper(ConfigManager.config["wallpaperPath"])
	
func _on_vol_slider_changed(value,bus):
	ConfigManager.config[bus] = value #Update config
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus),true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index(bus),false)
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(bus),
			-20 + ((value/100) * 20)
		)

func _on_open_file_pressed():
	$AccessFileScreen.show()
	
func _on_access_file_screen_change_wallpaper(path):
		changeWallpaper(path)
		ConfigManager.config["wallpaperPath"] = path

func changeWallpaper(path:String):
	if FileAccess.file_exists(path):
		if path.ends_with(".png") or path.ends_with(".jpeg") or path.ends_with(".jpg"):
		#Update Preview
			var img = Image.new()
			img.load(path)
			var wallpaper = ImageTexture.create_from_image(img)
			$ScrollContainer/SettingList/WallpaperControl/WPPrev.texture = wallpaper
		
			#Update WP
			phoneMenu.get_node("Wallpaper").texture = wallpaper
		
func _on_exit_button_pressed():
	ConfigManager.updateCFG()
	self.visible = false
	phoneMenu.visible = true


func _on_reset_pressed():
	#Update Preview
	var img = Image.new()
	img.load("res://Assets/Backgrounds/OceanBG.png")
	var wallpaper = ImageTexture.create_from_image(img)
	$ScrollContainer/SettingList/WallpaperControl/WPPrev.texture = wallpaper
	
	#Update WP
	phoneMenu.get_node("Wallpaper").texture = wallpaper
	ConfigManager.config["wallpaperPath"] = ""
