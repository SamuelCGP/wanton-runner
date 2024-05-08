extends Trap

onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	type = "CarPickup"
	connect("body_entered", self, "_on_body_entered")

func _process(delta: float) -> void:
	if kills >= max_kills:
		visible = false
	if !globals.is_race_running:
		visible = true
		kills = 0

func _on_body_entered(body: Node) -> void:
	if "is_dead" in body && kills < max_kills:
		body.is_car = true
		kills += 1
