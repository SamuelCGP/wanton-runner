class_name Snap
extends Node2D

# grid and area
const GRID_SIZE = 9
const CELL_SIZE = 35
const AREA_X_START = 23
const AREA_X_END = 337
const AREA_Y_START = 22
const AREA_Y_END = 336

var previous_cell = Vector2(0,0)
var cur_cell_pos = Vector2(0,0)

# sounds
const TOGGLE_1 = 0
const TOGGLE_2 = 0.06
const TOGGLE_3 = 0.14
const TOGGLE_4 = 0.21
const TOGGLE_5 = 0.28
const TOGGLE_6 = 0.36
const TOGGLE_7 = 0.43
const TOGGLE_END = 0.51
const OPTIONS = [TOGGLE_1, TOGGLE_2, TOGGLE_3, TOGGLE_4, TOGGLE_5, TOGGLE_6, TOGGLE_7]

var rand_index = TOGGLE_1
var end = TOGGLE_2

# sound players
onready var asp = get_node("toggle_sound_player")
onready var but_sell_sp = get_node("buy_sell_sound_player")
onready var error_sp = get_node("error_sound_player")

# trap preview
const spikes: PackedScene = preload("res://Spikes.tscn")
const killer: PackedScene = preload("res://Killer.tscn")
const money_bag: PackedScene= preload("res://MoneyBag.tscn")
const car_pickup: PackedScene = preload("res://CarPickup.tscn")
var cur_trap_preview: Node2D
var is_trap_rendered: bool = false

# mouse
var is_mouse_in: bool = false

onready var globals = get_node("/root/GlobalVariables")

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	
	# stops toggle sound
	if asp.get_playback_position() >= end :
		rand_index = randi() % OPTIONS.size()
		asp.stop()
	
	# limits to a certain area
	if mouse_pos.x < AREA_X_START || mouse_pos.x > AREA_X_END || mouse_pos.y < AREA_Y_START || mouse_pos.y > AREA_Y_END:
		reset()
		is_mouse_in = false
		return
	is_mouse_in = true
	
	# renders the selector
	if globals.is_race_running:
		reset()
		return
		
	render_selector(mouse_pos)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() && is_mouse_in:
		match event.button_index:
			BUTTON_LEFT:
				if !cur_trap_preview && !is_instance_valid(cur_trap_preview):
					return
				place_trap()
			BUTTON_RIGHT:
				if cur_trap_preview && is_instance_valid(cur_trap_preview):
					reset()
					globals.cur_trap = null
				remove_trap()
				
func reset() -> void:
	visible = false
	if cur_trap_preview && is_instance_valid(cur_trap_preview):
		cur_trap_preview.queue_free()
		cur_trap_preview = null
		is_trap_rendered = false

func render_selector(mouse_pos) -> void:
	# what cell is the cursor on?
	var cell_x = floor(range_lerp(mouse_pos.x, AREA_X_START, AREA_X_END - CELL_SIZE + 1, 1, GRID_SIZE))
	var cell_y = floor(range_lerp(mouse_pos.y, AREA_Y_START, AREA_Y_END - CELL_SIZE + 1, 1, GRID_SIZE))
	
	# plays the toggle sound
	if previous_cell.x != cell_x || previous_cell.y != cell_y:
		previous_cell.x = cell_x
		previous_cell.y = cell_y
		play_toggle_sound()
	
	# sets the position of the placement icon
	var new_position = Vector2(AREA_X_START + ((cell_x - 1) * CELL_SIZE), AREA_Y_START + ((cell_y - 1) * CELL_SIZE))
	cur_cell_pos = new_position
	visible = true
	position.x = new_position.x
	position.y = new_position.y
	
	# renders the trap placement preview, if one has been chosen
	render_trap_preview(new_position, Vector2(cell_x, cell_y))

func play_toggle_sound() -> void:	
	if rand_index + 1 < OPTIONS.size():
		end = OPTIONS[rand_index + 1]
	else:
		end = TOGGLE_END
	
	if !asp.playing:
		asp.play(OPTIONS[rand_index])
		
func render_trap_preview(new_position, cur_cell):
	if !is_trap_rendered:
		if globals.cur_trap != null:
			reset()
			match(globals.cur_trap):
				"buy_spikes":
					cur_trap_preview = spikes.instance()
				"buy_killer":
					cur_trap_preview = killer.instance()
				"buy_money_bag":
					cur_trap_preview = money_bag.instance()
				"buy_car_pickup":
					cur_trap_preview = car_pickup.instance()
			
			get_parent().add_child(cur_trap_preview)
			is_trap_rendered = true
			
	if cur_trap_preview	&& is_instance_valid(cur_trap_preview):
		cur_trap_preview.position = new_position
		
		# flips the preview
		if cur_trap_preview.type == "MoneyBag":
			return
		if cur_trap_preview.type == "Killer":
			if cur_cell.x == 9 && cur_cell.y == 5:
				cur_trap_preview.get_child(1).scale.x = -1
				return
			elif cur_cell.x == 1 && cur_cell.y == 8:
				cur_trap_preview.get_child(1).scale.x = 1
				return
				
		cur_trap_preview.get_child(1).scale.x = 1
		if cur_cell.y == 2 || cur_cell.y == 8:
			cur_trap_preview.get_child(1).scale.x = -1

func place_trap():	
	# checks if there is already a trap in the position
	for node in get_tree().get_nodes_in_group("traps"):
		if node.position == cur_trap_preview.position:
			if node.type == "BlockedCell":
				error_sp.play()
				return
			var sellOP = buy_or_sell_trap(node.type, false)
			if sellOP:
				node.queue_free()
	
	# buys the trap
	var buyOP = buy_or_sell_trap(cur_trap_preview.type)
	
	# places the trap
	if buyOP:
		cur_trap_preview.add_to_group("traps")
		cur_trap_preview = null
		is_trap_rendered = false
		globals.cur_trap = null
		return
		
	error_sp.play()

func remove_trap():
	for node in get_tree().get_nodes_in_group("traps"):
		if node.position == cur_cell_pos:
			if node.type == "BlockedCell":
				return
# warning-ignore:return_value_discarded
			buy_or_sell_trap(node.type, false)
			node.queue_free()

func buy_or_sell_trap(type, buy: bool = true) -> bool:
	var modifier = 1
	if buy:
		modifier = -1
		
	var value = 0
	
	match(type):
		"Spikes":
			value = (globals.SPIKE_VALUE * modifier)
		"Killer":
			value = (globals.KILLER_VALUE * modifier)
		"CarPickup":
			value = (globals.CAR_PICKUP_VALUE * modifier)
		"MoneyBag":
			value = (globals.MONEY_BAG_VALUE * modifier)
				
	if globals.money + value >= 0:
		globals.money += value
		but_sell_sp.pitch_scale = 1 + ((1 - modifier) * 0.5)
		but_sell_sp.play()
		return true
	return false
