extends Node

func createShiny(node:Node,fish:Fish):
	match fish.shinyOverride:
		2:
			node.get_material().set_shader_parameter("mode", fish.shinyOverride)
			node.get_material().set_shader_parameter("hueShiftDegrees", fish.shinyValue)
		3:
			node.get_material().set_shader_parameter("mode", fish.shinyOverride)
			node.get_material().set_shader_parameter("modulate", Vector4(
				fish.shinyValue.r,
				fish.shinyValue.g,
				fish.shinyValue.b,
				fish.shinyValue.a
				))
		4:
			node.texture = fish.shinyValue # Those who recycle :skull:
		_:
			node.get_material().set_shader_parameter("mode", fish.shinyOverride)
