extends Node2D

const NIVELES: Dictionary = {
	KEY_1: "res://Scenes/nivel_base.tscn",
	KEY_2: "res://Scenes/nivel_1.tscn",
}

func _process(_delta: float) -> void:
	# ESC: Salida inmediata
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		print("⚡ [DEBUG] Cerrando juego con ESC...")
		get_tree().quit()

	# Cambio de niveles con 1, 2, 3, 4
	for tecla in NIVELES:
		if Input.is_physical_key_pressed(tecla):
			var ruta = NIVELES[tecla]
			if ResourceLoader.exists(ruta):
				Global.posicion_jugador = Vector2i(0, 0)
				get_tree().change_scene_to_file(ruta)
			else:
				print("⚠️ No existe la escena en: ", ruta)
			break
