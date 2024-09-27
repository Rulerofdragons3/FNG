extends Control

#Import Shop and such
@onready var shop = $"../Shop"
@onready var bar = $"../Bar"
@onready var fishionary = $"../Fishionary"
@onready var map = $"../Map"
@onready var settings = $"../Settings"
@onready var tank = $"../Aquarium"

func _ready():
	$MoneyLabel.text = "$%.2f" % Globals.money
	$FishingHint.text = "Press "+ InputMap.action_get_events("StartMinigame")[0].as_text().replace(" (Physical)","") + " to start fishing"

func _input(_event):
	#Hide hint when game starts
	if Input.is_action_just_pressed("StartMinigame"):
		$FishingHint.visible = false
	#DEBUG
	elif Input.is_key_label_pressed(KEY_M):
		match Globals.world:
			"ocean":
				Globals.setWorldPool("nightOcean")
				print("Set to night")
			"nightOcean":
				Globals.setWorldPool("ocean")
				print("Set to day")

func _on_shop_button_pressed():
	shop.visible = true
	bar.canFish = false
	$Phone.visible = false
	
func _on_fishionary_button_pressed():
	fishionary.visible = true
	bar.canFish = false
	$Phone.visible = false

func _on_map_button_pressed():
	map.visible = true
	bar.canFish = false
	$Phone.visible = false

func _on_settings_button_pressed():
	settings.visible = true
	bar.canFish = false
	$Phone.visible = false

func _on_menu_button_pressed():
	$Phone.visible = true
	$MenuButton.visible = false
	bar.canFish = false
	$FishingHint.visible = false
	
func _on_off_button_pressed():
	$Phone.visible = false
	$MenuButton.visible = true
	bar.canFish = true
	$FishingHint.visible = true

func _on_tank_button_pressed():
	tank.visible = true
	bar.canFish = false
	$Phone.visible = false


func _on_fishing_hint_visibility_changed():
	$FishingHint.text = "Press "+ InputMap.action_get_events("StartMinigame")[0].as_text().replace(" (Physical)","") + " to start fishing"
