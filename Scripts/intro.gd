extends Control

@export var activar_portada: bool = true
@export var imagen_portada: Texture2D
@export var imagenes: Array[Texture2D] = []
@export_multiline var textos: Array[String] = []
@export_file("*.tscn") var escena_siguiente: String = "res://Scenes/nivel_1.tscn"
@export var velocidad_caracter: float = 0.03

@onready var fondo: TextureRect = $TextureRect
@onready var panel_texto: PanelContainer = $PanelContainer
@onready var caja_texto: RichTextLabel = $PanelContainer/MarginContainer/RichTextLabel
@onready var portada: Control = $Portada
@onready var titulo: Sprite2D = $Portada/Titulo
@onready var texto_empezar: Label = $Portada/TextoEmpezar

var indice_actual: int = 0
var en_portada: bool = false
var tween_texto: Tween
var tween_titulo: Tween
var tween_parpadeo: Tween

func _ready() -> void:
	caja_texto.scroll_active = true
	caja_texto.scroll_following = true
	
	if activar_portada:
		iniciar_portada()
	else:
		portada.visible = false
		panel_texto.visible = true
		mostrar_vineta(0)

func iniciar_portada() -> void:
	en_portada = true
	portada.visible = true
	panel_texto.visible = false
	if imagen_portada:
		fondo.texture = imagen_portada
	
	await get_tree().process_frame
	var pos_y_base: float = titulo.position.y
	var escala_base: Vector2 = titulo.scale
	
	# Flotación vertical + ligero pulso de escala en el Sprite2D del título
	tween_titulo = create_tween().set_loops()
	tween_titulo.tween_property(titulo, "position:y", pos_y_base - 6.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_titulo.parallel().tween_property(titulo, "scale", escala_base * 1.02, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_titulo.tween_property(titulo, "position:y", pos_y_base + 6.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_titulo.parallel().tween_property(titulo, "scale", escala_base, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Parpadeo suave de "ENTER para empezar"
	tween_parpadeo = create_tween().set_loops()
	tween_parpadeo.tween_property(texto_empezar, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween_parpadeo.tween_property(texto_empezar, "modulate:a", 0.25, 1.2).set_trans(Tween.TRANS_SINE)
	

func salir_de_portada() -> void:
	en_portada = false
	if tween_titulo:
		tween_titulo.kill()
	if tween_parpadeo:
		tween_parpadeo.kill()
	portada.visible = false
	panel_texto.visible = true
	mostrar_vineta(0)

func mostrar_vineta(idx: int) -> void:
	if idx >= textos.size():
		if escena_siguiente != "":
			get_tree().change_scene_to_file(escena_siguiente)
		else:
			ControlGlobal.cargar_nivel_por_indice(0)
		return
	
	indice_actual = idx
	if idx < imagenes.size():
		fondo.texture = imagenes[idx]
	
	caja_texto.visible_ratio = 0.0
	caja_texto.text = textos[idx]
	caja_texto.get_v_scroll_bar().value = 0.0
	
	if tween_texto:
		tween_texto.kill()
	
	var duracion: float = textos[idx].length() * velocidad_caracter
	tween_texto = create_tween()
	tween_texto.tween_property(caja_texto, "visible_ratio", 1.0, duracion)

func _input(event: InputEvent) -> void:
	if en_portada:
		if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
			get_viewport().set_input_as_handled()
			salir_de_portada()
		return

	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		if tween_texto and tween_texto.is_running():
			tween_texto.kill()
			caja_texto.visible_ratio = 1.0
		else:
			mostrar_vineta(indice_actual + 1)
