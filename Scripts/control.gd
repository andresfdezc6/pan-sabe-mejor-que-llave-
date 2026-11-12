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
]

var indice_nivel_actual: int = 0

func _ready() -> void:
	cargar_nivel_por_indice(0)
func _process(float) ->void:
	if Global.muerto:
		get_tree().change_scene_to_file(NIVELES[indice_nivel_actual])
		

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	else:
		cargar_nivel_por_indice(event.physical_keycode - KEY_1)

func cargar_nivel_por_indice(idx: int) -> void:
	if idx >= 0 and idx < NIVELES.size():
		indice_nivel_actual = idx
		get_tree().change_scene_to_file(NIVELES[idx])

func cargar_siguiente_nivel() -> void:
	cargar_nivel_por_indice(indice_nivel_actual + 1)
