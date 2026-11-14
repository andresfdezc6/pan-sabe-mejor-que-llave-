extends Control

@onready var texto_reiniciar: RichTextLabel = $RichTextLabel5

var puede_reiniciar: bool = false
var tween_parpadeo: Tween

func _ready() -> void:
	get_tree().paused = false
	Global.secreto = true
	# Parpadeo suave en el texto inferior
	tween_parpadeo = create_tween().set_loops()
	tween_parpadeo.tween_property(texto_reiniciar, "modulate:a", 0.25, 0.8).set_trans(Tween.TRANS_SINE)
	tween_parpadeo.tween_property(texto_reiniciar, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

	# Pequeña pausa de seguridad para no saltarse la pantalla si venías pulsando Espacio
	await get_tree().create_timer(0.4).timeout
	puede_reiniciar = true

func _input(event: InputEvent) -> void:
	if not puede_reiniciar:
		return

	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if tween_parpadeo:
			tween_parpadeo.kill()

		ControlGlobal.indice_nivel_actual = 0
		Global.muerto = false
		Global.locura = 0
		Global.locura_on = false
		Global.secreto = true
		get_tree().change_scene_to_file("res://Scenes/intro.tscn")
