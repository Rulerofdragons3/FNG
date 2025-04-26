extends Control

#Import Shop and such
@onready var shop = $"../Shop"
@onready var bar = $"../RodContainer"
@onready var fishionary = $"../Fishionary"
@onready var map = $"../Map"
@onready var settings = $"../Settings"
@onready var tank = $"../Aquarium"
@onready var inv = $"../Inventory"

func _ready():
	$MoneyLabel.text = "$%.2f" % Globals.money
	$FishingHint.text = "Press "+ InputMap.action_get_events("StartMinigame")[0].as_text().replace(" (Physical)","") + " to start fishing"

func _input(_event):
	#Hide hint when game starts
	if Input.is_action_just_pressed("StartMinigame"):
		$FishingHint.visible = false
	
func _on_shop_button_pressed():
	shop.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false
	
func _on_fishionary_button_pressed():
	fishionary.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false

func _on_map_button_pressed():
	map.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false

func _on_settings_button_pressed():
	settings.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false

func _on_menu_button_pressed():
	$Phone.visible = true
	$MenuButton.visible = false
	bar.get_child(0).canFish = false
	$FishingHint.visible = false
	
func _on_off_button_pressed():
	$Phone.visible = false
	$MenuButton.visible = true
	bar.get_child(0).canFish = true
	$FishingHint.visible = true

func _on_tank_button_pressed():
	tank.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false

func _on_inv_button_pressed():
	inv.visible = true
	bar.get_child(0).canFish = false
	$Phone.visible = false

func _on_fishing_hint_visibility_changed():
	$FishingHint.text = "Press "+ InputMap.action_get_events("StartMinigame")[0].as_text().replace(" (Physical)","") + " to start fishing"
