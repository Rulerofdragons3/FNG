extends Resource
class_name Purchase

@export var icon:Texture
@export var title:String = ""
@export_range(0.0,5.0,0.5) var stars:float = 4.5
@export_multiline var description:String = ""
@export var price:float = 1.0

func purchase():
	push_warning("Empty purchase")
