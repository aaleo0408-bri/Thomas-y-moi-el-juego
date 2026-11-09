extends Node

signal progress_changed

const SAVE_PATH := "user://gravity_runner_save.json"
const SAVE_VERSION := 1
const STARTING_LIVES := 5

@export var persistence_enabled := true
var lives: int = STARTING_LIVES
var best_stars: Dictionary = {}
var current_world: int = 0
var current_level: int = 0
var run_state: String = "title"

func _ready() -> void:
	if persistence_enabled:
		load_game()

func load_game() -> void:
	if not persistence_enabled:
		return
	if not FileAccess.file_exists(SAVE_PATH):
		lives = STARTING_LIVES
		best_stars = {}
		save_game()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		lives = STARTING_LIVES
		best_stars = {}
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("version", -1)) != SAVE_VERSION:
		lives = STARTING_LIVES
		best_stars = {}
		return
	lives = clampi(int(parsed.get("lives", STARTING_LIVES)), 0, STARTING_LIVES)
	var saved_stars: Variant = parsed.get("best_stars", {})
	best_stars = saved_stars if typeof(saved_stars) == TYPE_DICTIONARY else {}
	_validate_best_stars()

func _validate_best_stars() -> void:
	var valid_stars: Dictionary = {}
	for raw_key in best_stars.keys():
		var parts := str(raw_key).split("-", false, 1)
		if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
			continue
		var world := int(parts[0])
		var level := int(parts[1])
		if world < 0 or world >= 3 or level < 0 or level >= 10:
			continue
		var raw_stars: Variant = best_stars[raw_key]
		if typeof(raw_stars) != TYPE_INT and typeof(raw_stars) != TYPE_FLOAT:
			continue
		valid_stars[level_key(world, level)] = clampi(int(raw_stars), 0, 3)
	best_stars = valid_stars

func save_game() -> void:
	_validate_best_stars()
	lives = clampi(lives, 0, STARTING_LIVES)
	if not persistence_enabled:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("No se pudo guardar la partida.")
		return
	file.store_string(JSON.stringify({"version": SAVE_VERSION, "lives": lives, "best_stars": best_stars}))

func begin_new_run() -> void:
	if is_inside_tree():
		get_tree().paused = false
	lives = STARTING_LIVES
	current_world = 0
	current_level = 0
	run_state = "map"
	save_game()
	progress_changed.emit()

func level_key(world: int, level: int) -> String:
	return "%d-%d" % [world, level]

func stars_for(world: int, level: int) -> int:
	if world < 0 or world >= 3 or level < 0 or level >= 10:
		return 0
	return int(best_stars.get(level_key(world, level), 0))

func is_level_unlocked(world: int, level: int) -> bool:
	if world < 0 or world >= 3 or level < 0 or level >= 10:
		return false
	for previous_world in range(world):
		if stars_for(previous_world, 9) != 3:
			return false
	if level == 0:
		return true
	return stars_for(world, level - 1) == 3

func unlocked_worlds() -> int:
	var result := 1
	for world in range(2):
		if result != world + 1 or stars_for(world, 9) != 3:
			break
		result += 1
	return result

func start_level(world: int, level: int) -> bool:
	if world < 0 or world >= 3 or level < 0 or level >= 10:
		return false
	if lives <= 0 or not is_level_unlocked(world, level):
		return false
	current_world = world
	current_level = level
	run_state = "playing"
	return true

func record_clear(earned: int) -> void:
	var key := level_key(current_world, current_level)
	best_stars[key] = maxi(int(best_stars.get(key, 0)), clampi(earned, 0, 3))
	run_state = "results"
	save_game()
	progress_changed.emit()

func lose_life() -> bool:
	if lives <= 0:
		return false
	lives -= 1
	if lives == 0:
		run_state = "gameover"
	save_game()
	progress_changed.emit()
	return true

func continue_level() -> bool:
	return start_level(current_world, current_level)

func next_level() -> bool:
	if stars_for(current_world, current_level) < 3:
		return false
	var world := current_world
	var level := current_level + 1
	if level >= 10:
		world += 1
		level = 0
	return start_level(world, level)
