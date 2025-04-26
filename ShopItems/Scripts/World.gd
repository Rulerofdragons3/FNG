extends Purchase
class_name WorldUpgrade

@export var world:String = "ocean"

func purchase():
	if world not in Globals.obtainedWorlds:
		Globals.obtainedWorlds.append(world)
	else:
		push_warning("Player already has world: ", world, ".")
