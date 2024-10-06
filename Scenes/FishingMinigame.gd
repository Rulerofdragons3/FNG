extends ColorRect

#GLOBALS
var minigameActive = false
var speedChangeStep = 0 #Determines where to speed up/slow down
var barMoveSpeed = 0
var barChangedSpeed = 0
var catchStages = 1
var catchStage = 1
#Exports the variable so other scripts can access it
@export var canFish = true

#Signal
signal fishCaught(luckMult)

#Get Other Objects (Buttons)
@onready var menuButton = $"../Ui/MenuButton"

func _ready():
	$ReelMarker/MultiplierDisplay.text = ""

func inCatchArea():
	var ReelArea = [
	$ReelMarker.position.x,
	$ReelMarker.position.x + $ReelMarker.size.x
	]
	var CatchArea = [
		$CatchArea.position.x,
		$CatchArea.position.x + $CatchArea.size.x
	]
	#Determines if the Reelmarker is in the CatchArea box
	if (
		#Tests the front Area of the box
		(CatchArea[0] <= ReelArea[0] and ReelArea[0] <= CatchArea[1])
		or
		#Tests the back area of Reel Area
		(CatchArea[0] <= ReelArea[1] and ReelArea[1] <= CatchArea[1])
	):
		return true
	return false

func determineLuck():
	var luckMult = 0
	#Default case
	if catchStages == 0:
		var catchPos = $CatchArea.position.x
		if speedChangeStep == 0:
			luckMult = barMoveSpeed / (600 - catchPos)
		else:
			luckMult = (barChangedSpeed) / (catchPos - speedChangeStep)
		if luckMult < 1: 
			luckMult = 1 #Account for negatives
		luckMult = ceil(luckMult) * Globals.performanceMultiplier
	#Special case
	else:
		luckMult = catchStages * Globals.performanceMultiplier
	
	return luckMult			


#Detects input
func _input(_event):
	#Minigame Active Code
	if Input.is_action_just_pressed("StartMinigame") and minigameActive:
		if inCatchArea():
			if catchStage != 0:
				catchStage -= 1
				#Speed changes
				if (0 < barMoveSpeed) and (barMoveSpeed < 600):
					barMoveSpeed += 25
				else:
					barMoveSpeed -= 25
				barMoveSpeed *= -1
				
				#Fancy Stuff
				$ReelMarker/MultiplierDisplay.show()
				$ReelMarker/MultiplierDisplay.text = str(
					Globals.performanceMultiplier * (
					catchStages - catchStage)
					) + "x"
				#Sets catch area color from blue -> green 
				$CatchArea.color = Color(
					0,
					1 - (float(catchStage) / float(catchStages)),
					(float(catchStage) / float(catchStages))
				)
				#Sound
				$ComboCatch.pitch_scale = 0.40 + 0.60 * (
					float(catchStages - catchStage) / float(catchStages)
					)
				$ComboCatch.play()
				
				#Position changes
				if barMoveSpeed < 0: 
					$CatchArea.position = Vector2(
						randi_range(
							$CatchArea.position.x + 100,
							500),
						$CatchArea.position.y)
				else:
					$CatchArea.position = Vector2(
						randi_range(
							20,
							$CatchArea.position.x - 100),
						$CatchArea.position.y)
				
				
			#On fish caught
			else:
				minigameActive = false
				#Luck "logic"
				var luckMult = determineLuck()
				$ReelMarker/MultiplierDisplay.text = str(luckMult) + "x"
				$CatchArea.color = "00FF00"
				#Sounds
				$ReelingOut.stop()
				$FishCaught.play()
				await $FishCaught.finished
				
				reset(true, luckMult, randi_range(catchStages,10) == 10)
		else:
			$ReelMarker/MultiplierDisplay.text = "MISS"
			minigameActive = false
			reset()
			
	#Minigame Setup
	#Cancels if fishing conditions are not met
	if not canFish:
		return
	#Rahhhh
	if not Input.is_action_just_pressed("StartMinigame"):
		return
	
	#Disables buttons
	menuButton.disabled = true
	
	canFish = false
	
	#Updates catch hint
	$CatchArea/CatchHint.text = "(" + InputMap.action_get_events("StartMinigame")[0].as_text().replace(" (Physical)","") + ")"
	
	#------------------------------Setup------------------------------------
	var catchAreaPos = randi_range(0,400)
	$CatchArea.position += Vector2(catchAreaPos,0)
	$ReelMarker.position = Vector2(
		600,
		$ReelMarker.position.y
	)
	#Fishing Variables
	#Determines which minigame to choose
	match randi_range(1,20):
		1: #Multicatch
			#Determines how many time a fish will pull
			catchStages = randi_range(2,9)
			$CatchArea.color = "0000FF"
			barMoveSpeed = randi_range(2,3) * 100
		_: #Default
			catchStages = 0
			$CatchArea.color = "FF0000"
			barMoveSpeed = randi_range(1,5) * 100
	catchStage = catchStages
	#Determines where to speed up/slow down
	#Initial Move speed
	
	if barMoveSpeed < 150 and catchAreaPos < 400 and catchStage == 0:
		speedChangeStep = randi_range(catchAreaPos + 100,500)
		#Move speed on update
		barChangedSpeed = randi_range(1,5) * 100
	else:
		speedChangeStep = 0
		barChangedSpeed = 0
	
	
	
	#Setup finished, reveal to player
	$ReelingOut.play()
	self.visible = true
	minigameActive = true
	

func reset(caughtFish:bool = false, luckMult:float = 1.0, bigCatch:bool = false):
	$ReelingOut.stop()
	$ReelingIn.play()
	await get_tree().create_timer(1).timeout
	$ReelingIn.stop()
	self.visible = false
	#Resets parts to initial states
	$ReelMarker/MultiplierDisplay.text = ""
	$Reel.rotation = 0
	$ReelMarker.position = Vector2(0,$ReelMarker.position.y)
	$CatchArea.position  = Vector2(0,$CatchArea.position.y)
	if not caughtFish:
		$TinySplash.play()
		canFish = true
		#Reenable buttons
		menuButton.disabled = false
	else:
		$Splash.play()
		fishCaught.emit(luckMult,bigCatch)
	
	
func _physics_process(delta):
	if minigameActive:
		#Catches when the bar moves too far
		if ($ReelMarker.position.x < -10) or $ReelMarker.position.x > 610:
			minigameActive = false
			reset()
			return
			
		if speedChangeStep > 0 and $ReelMarker.position.x >= speedChangeStep and barMoveSpeed > 0:
			$ReelMarker.position.x -= barChangedSpeed * delta
			$Reel/Handle.rotation_degrees -= (barChangedSpeed * delta)
			
		else:
			$ReelMarker.position.x -= barMoveSpeed * delta
			$Reel/Handle.rotation_degrees -= (barMoveSpeed * delta)
	elif self.visible and (not minigameActive) and (not $FishCaught.playing):
		$Reel/Handle.rotation_degrees += 2000 * delta
			

	
