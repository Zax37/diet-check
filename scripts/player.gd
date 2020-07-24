extends Area2D

const Game = preload("res://scripts/game.gd")

var direction : Vector2

var tile_pos : Vector2
var target_tile_pos : Vector2
var prev_screen_pos : Vector2
var target_screen_pos : Vector2
var next_move_delay : float = 1.0
var timer : float = 0.0
var tempo : float = 1.5
var running = false

onready var game : Game = get_node("../..")
onready var path : Path2D = game.get_node("Path2D")

func _ready():
	set_process(true)
	target_tile_pos = tile_pos
	running = true

func _process(delta):
	if direction == Vector2.ZERO:
		if not running:
			return
		elif next_move_delay > 0.0:
			next_move_delay -= delta
			return

		prev_screen_pos = position
		direction = game.lead_to_goodie(tile_pos)
		target_tile_pos = tile_pos + direction
		target_screen_pos = game.to_screen_pos(target_tile_pos)
		tempo = 1.5
	else:
		timer += delta * tempo
		tempo += delta
		if timer >= 1.0:
			timer = 0.0
			tile_pos = target_tile_pos
			direction = Vector2.ZERO
			position = target_screen_pos
		else:
			position = prev_screen_pos * (1.0 - timer) \
					 + target_screen_pos * timer
	
#func _draw():
#	draw_circle(prev_screen_pos - get_global_position(), 8, Color.red)
#	draw_circle(target_screen_pos - get_global_position(), 8, Color.green)
	
func bounce():
	tempo *= 2
	timer = 0.9 - timer
	direction = -direction
	var swap = target_tile_pos
	target_tile_pos = tile_pos
	tile_pos = swap
	swap = prev_screen_pos
	prev_screen_pos = target_screen_pos
	target_screen_pos = swap
	next_move_delay = 1.0
	
func push():
	tempo *= 2.5
	next_move_delay = 1.0

func delay_next_move():
	next_move_delay = 1.0

func stop():
	running = false
