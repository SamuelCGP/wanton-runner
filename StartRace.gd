extends Panel

var is_mouse_in: bool = false

var pressed: bool = false
const GREEN = "22b14c"
const RED = "ff0000"
const GO = "GO"
const STOP = "STOP"
const WINS = "THE WANTON WINS"
const LOSES = "THE WANTON LOSES"
const DEAD = "WANTON IS DEAD\nGAME OVER"

onready var label = get_node("Go")
onready var victory_label = get_node("../../Square/Victory")
onready var globals = get_node("/root/GlobalVariables")

const runners = preload("res://Runners.tscn")

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	modulate = GREEN
	label.text = GO

func _process(delta: float) -> void:
	if globals.first_runner_decided:
		if globals.win:
			victory_label.modulate = RED
			victory_label.text = WINS
		else:
			victory_label.modulate = GREEN
			victory_label.text = LOSES
	else:
		if globals.is_wanton_dead:
			victory_label.modulate = RED
			victory_label.text = DEAD
		else:
			victory_label.text = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && \
	event.is_pressed() && \
	is_mouse_in:
		change_state()
		spawn_or_despawn_runners()
		globals.is_race_running = pressed

func change_state() -> void:
	pressed = !pressed
	modulate = GREEN
	label.text = GO
	if pressed:
		modulate = RED
		label.text = STOP
	globals.win = false
	globals.first_runner_decided = false
	globals.is_wanton_dead = false
		
func spawn_or_despawn_runners() -> void:
	var instanced_runners = runners.instance()
	if pressed:
		get_node("../../../").add_child(instanced_runners)
	else:
		# deletes all runners
		for node in get_tree().get_nodes_in_group("grouped_runners"):
			node.queue_free()

func _on_mouse_entered() -> void:
	is_mouse_in = true
	
func _on_mouse_exited() -> void:
	is_mouse_in = false
