extends Control

@export var imagenes: Array[Texture2D] = []
@export_multiline var textos: Array[String] = []
@export var velocidad_caracter: float = 0.03

@onready var fondo: TextureRect = $TextureRect
@onready var caja_texto: RichTextLabel = $PanelContainer/MarginContainer/RichTextLabel

var indice_actual: int = 0
var tween_texto: Tween

func _ready() -> void:
	mostrar_vineta(0)

func mostrar_vineta(idx: int) -> void:
	if idx >= textos.size():
		ControlGlobal.cargar_nivel_por_indice(0)
		return
	
	indice_actual = idx
	if idx < imagenes.size():
		fondo.texture = imagenes[idx]
	
	caja_texto.text = textos[idx]
	caja_texto.visible_ratio = 0.0
	
	if tween_texto:
		tween_texto.kill()
	
	var duracion: float = textos[idx].length() * velocidad_caracter
	tween_texto = create_tween()
	tween_texto.tween_property(caja_texto, "visible_ratio", 1.0, duracion)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		# Si el texto aún se está escribiendo, lo completa de golpe
		if tween_texto and tween_texto.is_running():
			tween_texto.kill()
			caja_texto.visible_ratio = 1.0
		# Si ya terminó de escribirse, pasa a la siguiente viñeta
		else:
			mostrar_vineta(indice_actual + 1)
