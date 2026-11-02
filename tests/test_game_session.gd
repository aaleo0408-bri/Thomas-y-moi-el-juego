extends SceneTree

const SESSION_SCRIPT := preload("res://scripts/game_session.gd")
var failures := 0

func _initialize() -> void:
	var session: Node = SESSION_SCRIPT.new()
	session.persistence_enabled = false
	root.add_child(session)
	session.lives = 5
	session.best_stars.clear()
	session.best_stars["0-9"] = 3
	session.begin_new_run()
	_check(session.stars_for(0, 9) == 3, "Nueva partida no borra progreso guardado")
	_check(session.lives == 5, "Nueva partida inicia con cinco vidas")
	_check(session.is_level_unlocked(0, 0), "Desbloquea el primer nivel")
	_check(not session.is_level_unlocked(0, 1), "Bloquea el siguiente con menos de tres estrellas")
	session.current_world = 0
	session.current_level = 0
	session.record_clear(2)
	_check(not session.is_level_unlocked(0, 1), "Dos estrellas no desbloquean el siguiente")
	_check(not session.next_level(), "No permite avanzar con dos estrellas")
	session.current_level = 1
	session.record_clear(3)
	_check(session.is_level_unlocked(0, 2), "Tres estrellas desbloquean siguiente")
	session.current_level = 9
	session.record_clear(3)
	_check(session.unlocked_worlds() == 2, "Tres estrellas en final de mundo desbloquean mundo siguiente")
	_check(session.is_level_unlocked(1, 0), "Desbloquea nivel inicial del segundo mundo")
	session.best_stars["0-9"] = 0
	session.best_stars["1-9"] = 3
	_check(session.unlocked_worlds() == 1, "No permite saltarse un mundo bloqueado")
	_check(not session.is_level_unlocked(1, 0), "No desbloquea mundos posteriores saltándose el anterior")
	session.best_stars["0-9"] = 3
	session.lives = 5
	var previous := session.lives
	_check(session.lose_life(), "Registra pérdida de vida")
	_check(session.lives == previous - 1, "Una muerte resta una sola vida")
	_check(session.lives == 4, "Cambios de nivel no regeneran vidas")
	session.lives = 1
	session.lose_life()
	_check(session.lives == 0 and session.run_state == "gameover", "Cero vidas termina la partida")
	_check(not session.start_level(0, 0), "No inicia niveles sin vidas")
	_check(not session.start_level(3, 0), "Rechaza índice de mundo inválido")
	_check(not session.start_level(0, 10), "Rechaza índice de nivel inválido")
	_check(session.stars_for(-1, 0) == 0, "Progreso inválido devuelve cero estrellas")
	_check(not session.is_level_unlocked(0, 10), "No desbloquea índices de nivel inválidos")
	session.best_stars["dato-corrupto"] = 3
	session.best_stars["3-0"] = 3
	session.best_stars["0-10"] = 3
	session.best_stars["0-3"] = "muchas"
	session._validate_best_stars()
	_check(not session.best_stars.has("dato-corrupto") and not session.best_stars.has("3-0") and not session.best_stars.has("0-10") and not session.best_stars.has("0-3"), "Descarta progreso corrupto o fuera de rango")
	session.best_stars["0-2"] = 1
	session.current_world = 0
	session.current_level = 2
	session.record_clear(0)
	_check(session.stars_for(0, 2) == 1, "No reemplaza un récord con menos estrellas")
	session.record_clear(3)
	_check(session.stars_for(0, 2) == 3, "Mejora el récord al conseguir más estrellas")
	if failures == 0:
		print("PASS: todas las pruebas del gestor de sesión")
	else:
		printerr("FAIL: %d pruebas fallaron" % failures)
	quit(1 if failures > 0 else 0)

func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		printerr("FAIL: ", description)
