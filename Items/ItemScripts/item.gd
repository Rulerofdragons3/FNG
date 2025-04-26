extends Resource
class_name Item

@export var texture:Texture
@export var stackable:bool = true
@export var consumable:bool = true
@export var trashable:bool = true
@export var mergeable:bool = false
@export var displayName:String
@export_multiline var description:String
var count:int = 0

func depleteCount(amount:int = 1):
	if consumable:
		count -= amount
		
		
		if count <= 0:
			count = 0
			Globals.inUseItems.erase(self)
			Globals.reUseItems.erase(self)
			self.unequipped()
		elif self not in Globals.reUseItems:
			Globals.inUseItems.erase(self)
			self.unequipped()

	return count

func incrementCount(amount:int = 1):
	if stackable:
		count += amount

func equipped():
	return

func unequipped():
	return
