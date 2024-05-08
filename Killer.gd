extends Trap

onready var damage_sp = get_node("Damage")
onready var raycast = get_node("Position2D/RayCast2D")
onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	type = "Killer"
	
func _process(_delta: float) -> void:
	if kills >= max_kills:
		visible = false
		raycast.enabled = false
	if !globals.is_race_running:
		visible = true
		raycast.enabled = true
		kills = 0
	if raycast.is_colliding():
		var body = raycast.get_collider()
		if !is_instance_valid(body):
			return
		if "is_dead" in body:
			body.is_dead = true
			kills += 1
			damage_sp.play()
