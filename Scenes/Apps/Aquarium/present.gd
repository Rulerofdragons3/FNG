extends Control

var item:Item
var subDir:String
var pool:Dictionary = preload("res://Items/FishPresents.json").data

func chooseItem() -> String:
	var maximum = 0
	for choice in pool:
		maximum += pool[choice]
	
	var randNum = randi_range(0,maximum)
	for choice:String in pool: 
		if randNum < pool[choice]:
			return choice
		randNum -= pool[choice]
	return "ShinyCharms/pity_shiny_charm.res"
	
func _ready():
	$PresentIcon.get_material().set_shader_parameter("mode", 2)
	$PresentIcon.get_material().set_shader_parameter("hueShiftDegrees", randf_range(0.0,360.0))
	subDir = chooseItem()
	item = load("res://Items/ItemData/" + subDir)
	$ItemDisplay/Item.texture = item.texture
	$ItemDisplay/NameLabel.text = item.displayName

func _on_present_icon_pressed() -> void:
	self.reparent(self.find_parent("SubViewport"))
	self.rotation = 0
	$PresentIcon.disabled = true
	$AnimationPlayer.play("Open")
	$ItemDisplay.show()
	ItemManager.giveItem(subDir)
	await $AnimationPlayer.animation_finished
	self.queue_free()
