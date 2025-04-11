extends Control
@onready var bar = $"../Bar"
@onready var UIMoney = $"../Ui/MoneyLabel"
@onready var menuButton = $"../Ui/MenuButton"
var plguffer:Fish = preload("res://FishData/Resources/Default/plguffer.res")
#Get World Fish
#var ID:String
var isShiny:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Hides at start
	self.visible = false
	#print($BG/FishSprites.sprite_frames.get_frame_texture("default",0))

#Is triggered from the FishingMinigame script
func _on_bar_fish_caught(luckMult,bigCatch):
	if Globals.worldPool == []:
		print("No fish in world pools")
		return
	var fish = determineFish(luckMult,bigCatch)
	displayFishInfo(fish)
	await $Dismiss.pressed
	on_dismiss_pressed(fish)

func determineFish(luckMult, bigCatch:bool = false):
	#Determines if it is shiny or not
	#8192
	if randi_range(0,2000) <= 2000 * (Globals.shinyOdds/100):
		isShiny = true
	else:
		isShiny = false
	#Rolls for a fish five times
	for i in range(5):
		var selectedFish:Fish = Globals.worldPool.pick_random()
		var rarity:int = selectedFish.rarity
		#Minimum num to roll to ensure catch
		var minRoll = 1 * (luckMult * Globals.performanceMultiplier)
		
		#If the fish is determined to be a "big catch", then it will automatically be caught
		if bigCatch == true: 
			if "bigCatch" in selectedFish:
				return selectedFish
		
		if randi_range(1, rarity) <= minRoll:
			#Translates from worldpool to fishData index
			#I just don't want to rewrite how this script & fishionary works
			return selectedFish
	return plguffer #Default fish if all goes wrong

func calculateFishValue(fishValue):
	if fishValue <= Globals.cheapValueMultiplier:
		fishValue *= -fishValue + (Globals.cheapValueMultiplier + 1)
	if isShiny:
		fishValue *= 2
	return fishValue

func displayFishInfo(fish:Fish):
	var valueText = "$" + "%.2f" % calculateFishValue(fish.value)
	if fish.shinyOverride == fish.ShinyOverrides.None:
		isShiny = false
	
	#Shiny control
	if isShiny:
		ShinyHandler.createShiny($BG/FishSprite, fish)
		$ShinyCatch.play()
		$BG/Sparkles.show()
		$BG/Sparkles.play()
		if fish.shinyDescription != "":
			$Fiscription.text = fish.shinyDescription
		else:
			$Fiscription.text = fish.description
	else:
		$BG/FishSprite.get_material().set_shader_parameter("mode", 6)
		$BG/Sparkles.hide()
		$BG/Sparkles.stop()
		$Fiscription.text = fish.description
		
	$BG/FishSprite.texture = fish.texture
	$Name.text = fish.name
	$Value.text = valueText
	bar.visible = false
	self.visible = true
	# Probably should remove this code eventually...
	if fish.name == "the angler" or fish.name == "pandemonium":
		$JokeAudioContainer/PressureIdle.play()
	
		#NewFish Control
	if (fish.resource_path not in Globals.obtainedFishIDs) or (
		isShiny and (Globals.obtainedFishIDs[fish.resource_path]["caughtShiny"] == 0)):
		$BG/NewIndicator.show()
		$BG/NewIndicator/PulseAnim.play("pulse")
		$Dismiss.disabled = true
		$NewFishTimer.start()
		await $NewFishTimer.timeout
		$Dismiss.disabled = false

func on_dismiss_pressed(fish:Fish):
	#Update Globals
	if fish.resource_path not in Globals.obtainedFishIDs: #Test to see if fish is obtained
		if !isShiny:
			Globals.obtainedFishIDs.merge({fish.resource_path:{"caught":1,"caughtShiny":0}})
		else:
			Globals.obtainedFishIDs.merge({fish.resource_path:{"caught":0,"caughtShiny":1}})
	else:
		if !isShiny:
			Globals.obtainedFishIDs[fish.resource_path]["caught"] += 1
		else:
			Globals.obtainedFishIDs[fish.resource_path]["caughtShiny"] += 1
	
	#Trigger items
	ItemManager.triggerItems(ItemManager.Events.OnFished)
	
	Globals.money += calculateFishValue(fish.value) 
	SaveManager.save_game()
	#UpdateUI
	$BG/NewIndicator.hide()
	$BG/NewIndicator/PulseAnim.stop()
	if fish.name == "the angler" or fish.name == "pandemonium":
		$JokeAudioContainer/PressureIdle.stop()
		$JokeAudioContainer/PressureJumpscare.play()
		$Fiscription.hide()
		$Name.hide()
		$Value.hide()
		$Dismiss.hide()
		var tween = create_tween()
		tween.tween_property($BG/FishSprite, "scale", Vector2(300,300),0.5)
		tween.play()
		await tween.finished
		#get_tree().quit(-1)
		OS.crash("Couldn't Hide...")
		return
	
	self.visible = false
	UIMoney.text = "$" + "%.2f" % Globals.money
	menuButton.disabled = false
	bar.canFish = true
	
