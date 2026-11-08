#PONLE QUE DIGA: VIBECODEO HASTA LA MUERTE
extends Node

# Lista ordenada de niveles
const NIVELES: Array[String] = [
	"res://Scenes/nivel_1.tscn", # Índice 0 -> Tecla 1
	"res://Scenes/nivel_2.tscn",    # Índice 1 -> Tecla 2
]

# Mapa de teclas para depuración
const TECLAS_DEBUG: Dictionary = {
	KEY_1: 0,
	KEY_2: 1,
}

var indice_nivel_actual: int = 0

func _ready() -> void:
	cargar_nivel_por_indice(0)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return
	# ESC: Salir del juego
	if event.physical_keycode == KEY_ESCAPE:
		print("⚡ [DEBUG] Cerrando juego con ESC...")
		get_tree().quit()

	# Teclas 1, 2, 3... para cambiar/reiniciar nivel
	if event.physical_keycode in TECLAS_DEBUG:
		var idx: int = TECLAS_DEBUG[event.physical_keycode]
		cargar_nivel_por_indice(idx)

func cargar_nivel_por_indice(idx: int) -> void:
	if idx >= 0 and idx < NIVELES.size():
		var ruta = NIVELES[idx]
		if ResourceLoader.exists(ruta):
			indice_nivel_actual = idx
			Global.posicion_jugador = Vector2i(0, 0)
			get_tree().change_scene_to_file(ruta)
		else:
			print("⚠️ No existe la escena en: ", ruta)

func cargar_siguiente_nivel() -> void:
	var siguiente_idx: int = indice_nivel_actual + 1
	
	if siguiente_idx < NIVELES.size():
		cargar_nivel_por_indice(siguiente_idx)
	else:
		print("🎉 ¡Juego completado! No hay más niveles.")
