extends Trap

onready var timer = get_node("Timer")
onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	type = "MoneyBag"
	timer.connect("timeout", self, "_on_timer_timeout")
	
func _process(delta: float) -> void:
	if !globals.is_race_running:
		visible = true
		type = "MoneyBag"
		kills = 0
		
func activate() -> void:
	if kills < max_kills:
		kills += 1
		timer.start()

func _on_timer_timeout():
	visible = false
	type = "EmptyMoneyBag"
