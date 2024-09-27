extends Control

@onready var phoneMenu = $"../Ui/Phone"
@onready var menuButton = $"../Ui/MenuButton"
@onready var BG = $"../Background"
@onready var shop = $"../Shop"



var siteDataFile = "res://Advertisements/websiteData.json"
var siteData = JSON.parse_string(
	FileAccess.get_file_as_string(siteDataFile)
)

func generateWebsite(ID):
	if str(ID) in siteData:
		var site = siteData[str(ID)]
		var textFile = "res://Advertisements/AdPages/" + site["PageData"]
		var siteText = "[outline_size=4][outline_color=#000000][font n=res://Assets/Fonts/joystixMonospace.otf s=20]" 
		siteText += FileAccess.get_file_as_string(textFile)
		#print(FileAccess.get_open_error())
		#Page Customization
		$ScrollContainer/VBoxContainer/ShopTitleContainer/URL.text = "hppts://" + site["URL"]
		$ScrollContainer/VBoxContainer/Content.text = siteText
		$BG.color = site["pageColor"]
	else:
		$BG.color = "#FFFFFF"
		$ScrollContainer/VBoxContainer/ShopTitleContainer/URL.text = "hppts://redirect.adspice.com"
		$ScrollContainer/VBoxContainer/Content.text = "[outline_size=4][outline_color=#000000]
		[font n=res://Assets/Fonts/joystixMonospace.otf s=80]404
		[font_size=40]Page does not exist.
		"

func _on_content_meta_clicked(meta):
	if meta.begins_with("https://"):
		OS.shell_open(meta)
	if meta == "joinCult":
		if "dreadSea" in Globals.obtainedWorlds:
			print("Already Joined")
		elif ("deepOcean" in Globals.obtainedWorlds) and (48 in Globals.obtainedFishIDs):
			Globals.obtainedWorlds.append("dreadSea")
		else:
			pass
		return
	
	
func _on_back_button_pressed():
	self.hide()
	shop.show()

func _on_exit_button_pressed():
	hide()
	self.visible = false
	phoneMenu.visible = true	
