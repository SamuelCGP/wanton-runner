extends Label

onready var globals = get_node("/root/GlobalVariables")

func _process(_delta) -> void:
	text = "$ " + str(globals.money)

