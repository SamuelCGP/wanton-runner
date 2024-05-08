extends Area2D

onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node) -> void:
	if globals.first_runner_decided:
		return
	
	if "is_wanton" in body:
		if body.is_wanton:
			globals.win = true
		globals.first_runner_decided = true
