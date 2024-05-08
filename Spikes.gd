extends Trap

onready var sprite = get_node("Icon")
onready var damage_sp = get_node("Damage")
onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	type = "Spikes"
	max_kills = 3
	connect("body_entered", self, "_on_body_entered")
	
func _process(delta: float) -> void:
	if kills >= max_kills:
		visible = false
	match(kills):
		0, 3:
			pass
		1:
			sprite.frame = 1
		2:
			sprite.frame = 2
	if !globals.is_race_running:
		visible = true
		sprite.frame = 0
		kills = 0
		
func _on_body_entered(body: Node) -> void:
	if "is_dead" in body && kills < max_kills:
		body.is_dead = true
		kills += 1
		damage_sp.play()
