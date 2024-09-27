extends Control

#Reference Variable(s)
var fishScene = preload("res://Scenes/tankfish.tscn")
var container:Node
var BG:Node 
var fishReferences = []

func _ready():
	$Bubble.hide()
	$Tail1.hide()
	$Tail2.hide()
	$Speech.text = ""

func _on_tree_entered():
	if len(Globals.obtainedFishIDs) <= 0:
		self.queue_free()
		return
	container = self.get_parent().get_parent()
	BG = container.get_node("BG")
	var y = randi_range(0, BG.size.y)
	instantiateFish($Pos1,0,y)
	instantiateFish($Pos2,1,y)
	
	var waitTime = 0
	#Set StartConversation timer
	if ($Pos1.global_position.x) < (BG.size.x - $Pos2.global_position.x):
		waitTime = 0.5 + (
			BG.size.x - $Pos2.global_position.x) / 100
	else:
		waitTime = 0.5 + ($Pos1.global_position.x) / 100
	#Regular timers don't work sowwy :(
	await get_tree().create_timer(waitTime).timeout
	startConversation()
	
func instantiateFish(posNode:Node,i,y):
	if len(Globals.obtainedFishIDs) <= 0:
		return
	
	var tankfish = fishScene.instantiate()
	var ID = Globals.obtainedFishIDs.pick_random()
	tankfish.fishID = ID
	tankfish.forceGoto = posNode.global_position
	if "tankIsMirrored" in Globals.fishData[ID]:
		tankfish.isMirrored = Globals.fishData[ID]["tankIsMirrored"]
	
	container.get_node("FishContainer").add_child(tankfish)
	tankfish.create(
		i * BG.size.x,
		posNode.global_position.y
	)
	fishReferences.append(tankfish)

#########################Conversation control##################################
func startConversation():
	var conversations:PackedStringArray = DirAccess.get_files_at("res://Dialogues/")
	var ok = false
	var convData:Dictionary
	while !ok:
		ok = true
		#Swag
		convData = JSON.parse_string(
			FileAccess.get_file_as_string(
				"res://Dialogues/" + conversations[
					randi_range(0,len(conversations) - 1)
					]
			)
		)
		#Bad conditions		
		#Add these later
	
	playConvo(convData)
	
	
func playConvo(convData:Dictionary):
	$Bubble.show()
	var conversation = convData["conversation"]
	for dialog in conversation:
		if dialog["speaker"] == "left":
			if dialog["text"].find("%s") != -1:
				$Speech.text = dialog["text"] % fishReferences[1].fishName
			else:
				$Speech.text = dialog["text"]
			$Tail1.show()
			$Tail2.hide()
		elif dialog["speaker"] == "right":
			if dialog["text"].find("%s") != -1:
				$Speech.text = dialog["text"] % fishReferences[0].fishName
			else:
				$Speech.text = dialog["text"]
				
			$Tail1.hide()
			$Tail2.show()
		elif dialog["speaker"] == "both":
			$Speech.text = dialog["text"]
			$Tail1.show()
			$Tail2.show()
		else:
			print("Invalid conversation type in " + dialog["text"])
		
		await get_tree().create_timer(dialog["displayTime"]).timeout
	#Conversation over. Dismiss fish
	for fish in fishReferences:
		fish.dismiss()
	
	self.queue_free()
