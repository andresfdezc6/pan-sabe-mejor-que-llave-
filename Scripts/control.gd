extends Node

const NIVELES: Array[String] = [
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
	"res://Scenes/nivel_14.tscn",
	"res://Scenes/nivel_15.tscn",
	"res://Scenes/nivel_16.tscn",
	"res://Scenes/nivel_final.tscn"
]

var speedrun_visible: bool = true
var speedrun_corriendo: bool = false
var tiempo_speedrun: float = 0.0
var speedrun_formateado: String = "00:00.00"
var dev_usado: bool = false

func reiniciar_speedrun() -> void:
	tiempo_speedrun = 0.0
	speedrun_formateado = "00:00.00"
	speedrun_corriendo = true

func formatear_tiempo(t: float) -> String:
	var horas: int = int(t) / 3600
	var minutos: int = (int(t) % 3600) / 60
	var segundos: int = int(t) % 60
	var centesimas: int = int(fmod(t, 1.0) * 100.0)
	if horas > 0:
		return "%02d:%02d:%02d.%02d" % [horas, minutos, segundos, centesimas]
	return "%02d:%02d.%02d" % [minutos, segundos, centesimas
]
const SONIDO_VICTORIA: AudioStream = preload("res://assets/sounds/victoria1.wav")
func reproducir_puerta() -> void:
	if SONIDO_VICTORIA:
		var player := AudioStreamPlayer.new()
		player.stream = SONIDO_VICTORIA
		add_child(player)
		player.finished.connect(player.queue_free)
		player.play()

const ESCENA_FINAL_VERDADERO: String = "res://Scenes/final_verdadero.tscn"

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

func _process(delta: float) -> void:
	if speedrun_corriendo:
		tiempo_speedrun += delta
		speedrun_formateado = formatear_tiempo(tiempo_speedrun)
	if Global.muerto:
		Global.muerto = false
		cargar_nivel_por_indice(indice_nivel_actual)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
	elif event.physical_keycode == KEY_F11:
		var ventana := get_window()
		if ventana.mode == Window.MODE_FULLSCREEN:
			ventana.mode = Window.MODE_WINDOWED
		else:
			ventana.mode = Window.MODE_FULLSCREEN
		return
	elif event.physical_keycode == KEY_1:
		cargar_nivel_por_indice(indice_nivel_actual - 1)
	elif event.physical_keycode == KEY_2 and (indice_nivel_actual < Global.nivel_alcanzado or Global.modo_dev):
		cargar_siguiente_nivel()
	elif event.physical_keycode == KEY_R:
		cargar_nivel_por_indice(indice_nivel_actual)
	elif event.physical_keycode == KEY_F:
		dev_usado = true
		if Global.modo_dev:
			print ("modo dev off")
			Global.modo_dev = false
		else:
			print("modo dev on")
			Global.modo_dev = true
	elif event.is_action_pressed("toggle_speedrun"):
		speedrun_visible = not speedrun_visible

func cargar_nivel_por_indice(idx: int) -> void:
	if idx >= 0 and idx < NIVELES.size():
		indice_nivel_actual = idx
		get_tree().change_scene_to_file(NIVELES[idx])

func cargar_siguiente_nivel() -> void:
	if indice_nivel_actual == NIVELES.size() - 1 and Global.secreto_on:
		get_tree().change_scene_to_file(ESCENA_FINAL_VERDADERO)
		return
	cargar_nivel_por_indice(indice_nivel_actual + 1)
	if indice_nivel_actual > Global.nivel_alcanzado or Global.modo_dev:
		Global.nivel_alcanzado = indice_nivel_actual
