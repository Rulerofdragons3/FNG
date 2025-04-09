extends Control
@onready var bar = $"../Bar"
@onready var UIMoney = $"../Ui/MoneyLabel"
@onready var menuButton = $"../Ui/MenuButton"
#@onready var fishSprites = $"../FishSprites"
#Get World Fish
var ID:String = "plguffer"
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
	ID = Globals.fishData[fish]["id"]
	displayFishInfo(fish)

func determineFish(luckMult, bigCatch:bool = false):
	var datLen = len(Globals.worldPool) - 1
	#Determines if it is shiny or not
	#8192
	if randi_range(0,2000) <= 2000 * (Globals.shinyOdds/100):
		isShiny = true
	else:
		isShiny = false
	#Rolls for a fish five times
	for i in range(5):
		var selectedFish:Dictionary = Globals.fishData[
			Globals.worldPool[randi_range(0,datLen)]
			]
		var fishID:String = selectedFish["id"]
		var rarity:int = selectedFish["rarity"]
		#Minimum num to roll to ensure catch
		var minRoll = 1 * (luckMult * Globals.performanceMultiplier)
		
		#If the fish is determined to be a "big catch", then it will automatically be caught
		if bigCatch == true: 
			if "bigCatch" in selectedFish:
				return fishID
		
		if randi_range(1, rarity) <= minRoll:
			#Translates from worldpool to fishData index
			#I just don't want to rewrite how this script & fishionary works
			return fishID
	print("Failed")
	return "plguffer" #Default fish if all goes wrong

func calculateFishValue(fishValue):
	if fishValue <= Globals.cheapValueMultiplier:
		fishValue *= -fishValue + (Globals.cheapValueMultiplier + 1)
	if isShiny:
		fishValue *= 2
	return fishValue

func loadTexture(id):
	var imagePath = "res://Assets/Fish/" + Globals.fishData[id]["texture"]
	var texture
	if FileAccess.file_exists(imagePath):
		texture = load(imagePath)
	else:
		texture = load("res://Assets/Buttons/ExitUP.png")
	return texture

func displayFishInfo(id:String):
	var valueText = "$" + "%.2f" % calculateFishValue(Globals.fishData[id]['value'])
	var texture = loadTexture(id) #fishSprites.sprite_frames.get_frame_texture("default",id)
	if "shinyOverride" in Globals.fishData[id] and Globals.fishData[id]["shinyOverride"] == "none":
		isShiny = false
	
	#Shiny control
	if isShiny:
		if "shinyOverride" in Globals.fishData[id]: 
			$BG/FishSprite.texture = ShinyHandler.createShiny(
				texture.get_image(),
				Globals.fishData[id]["shinyOverride"]
			)
		else:
			$BG/FishSprite.texture = ShinyHandler.createShiny(texture.get_image())
		$ShinyCatch.play()
		$BG/Sparkles.show()
		$BG/Sparkles.play()
		if "shinyDesc" in Globals.fishData[id]:
			$Fiscription.text = Globals.fishData[id]['shinyDesc']
		else:
			$Fiscription.text = Globals.fishData[id]['desc']
	else:
		$BG/FishSprite.texture = texture
		$BG/Sparkles.hide()
		$BG/Sparkles.stop()
		$Fiscription.text = Globals.fishData[id]['desc']
	
	$Name.text = Globals.fishData[id]['name']
	$Value.text = valueText
	bar.visible = false
	self.visible = true
	# Probably should remove this code eventually...
	if Globals.fishData[id]["id"] == "the_angler" or Globals.fishData[id]["id"] == "pandemonium":
		$JokeAudioContainer/PressureIdle.play()
	
		#NewFish Control
	if (id not in Globals.obtainedFishIDs) or (isShiny and (Globals.obtainedFishIDs[id]["caughtShiny"] == 0)):
		$BG/NewIndicator.show()
		$BG/NewIndicator/PulseAnim.play("pulse")
		$Dismiss.disabled = true
		$NewFishTimer.start()
		await $NewFishTimer.timeout
		$Dismiss.disabled = false

func _on_dismiss_pressed():
	#Update Globals
	if ID not in Globals.obtainedFishIDs: #Test to see if fish is obtained
		if !isShiny:
			Globals.obtainedFishIDs.merge({ID:{"caught":1,"caughtShiny":0}})
		else:
			Globals.obtainedFishIDs.merge({ID:{"caught":0,"caughtShiny":1}})
	else:
		if !isShiny:
			Globals.obtainedFishIDs[ID]["caught"] += 1
		else:
			Globals.obtainedFishIDs[ID]["caughtShiny"] += 1
	
	#Trigger items
	ItemManager.triggerItems(ItemManager.Events.OnFished)
	
	Globals.money += calculateFishValue(Globals.fishData[ID]['value']) 
	SaveManager.save_game()
	
	#UpdateUI
	$BG/NewIndicator.hide()
	$BG/NewIndicator/PulseAnim.stop()
	if Globals.fishData[ID]['name'] == "the angler" or Globals.fishData[ID]['name'] == "pandemonium":
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
	
