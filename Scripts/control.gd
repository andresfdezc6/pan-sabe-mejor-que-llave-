extends Node

const NIVELES: Array[String] = [
	"res://Scenes/nivel_1.tscn",
	"res://Scenes/nivel_2.tscn",
	"res://Scenes/nivel_3.tscn",
	"res://Scenes/nivel_4.tscn",
	"res://Scenes/nivel_5.tscn",
	"res://Scenes/nivel_6.tscn",
	"res://Scenes/nivel_7.tscn",
	"res://Scenes/nivel_8.tscn",
	"res://Scenes/nivel_9.tscn",
	"res://Scenes/nivel_10.tscn",
	"res://Scenes/nivel_11.tscn",
	"res://Scenes/nivel_12.tscn",
	"res://Scenes/nivel_13.tscn",
]

var indice_nivel_actual: int = 0

func _ready() -> void:
	_sincronizar_nivel_inicial.call_deferred()

func _sincronizar_nivel_inicial() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if not tree:
		return
	var escena_actual := tree.current_scene
	if escena_actual and escena_actual.scene_file_path in NIVELES:
		indice_nivel_actual = NIVELES.find(escena_actual.scene_file_path)

func _process(_delta: float) -> void:
	if Global.muerto:
		Global.muerto = false
		get_tree().change_scene_to_file(NIVELES[indice_nivel_actual])

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	elif event.physical_keycode == KEY_1:
		cargar_nivel_por_indice(indice_nivel_actual - 1)
	elif event.physical_keycode == KEY_2:
		cargar_siguiente_nivel()
	elif event.physical_keycode == KEY_R:
		cargar_nivel_por_indice(indice_nivel_actual)

func cargar_nivel_por_indice(idx: int) -> void:
	if idx >= 0 and idx < NIVELES.size():
		indice_nivel_actual = idx
		get_tree().change_scene_to_file(NIVELES[idx])

func cargar_siguiente_nivel() -> void:
	cargar_nivel_por_indice(indice_nivel_actual + 1)
