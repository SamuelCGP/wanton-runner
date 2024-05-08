extends Panel

var is_mouse_in: bool = false

onready var price = get_node("Price")
onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	match(name):
		"buy_spikes":
			price.text = str(globals.SPIKE_VALUE) + "\n$"
		"buy_killer":
			price.text = str(globals.KILLER_VALUE) + "\n$"
		"buy_money_bag":
			price.text = str(globals.MONEY_BAG_VALUE) + "\n$"
		"buy_car_pickup":
			price.text = str(globals.CAR_PICKUP_VALUE) + "\n$"
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && \
	event.is_pressed() && \
	is_mouse_in:
		globals.cur_trap = name

func _on_mouse_entered() -> void:
	is_mouse_in = true
	
func _on_mouse_exited() -> void:
	is_mouse_in = false
