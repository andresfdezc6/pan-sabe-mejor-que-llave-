extends Control

@onready var sprite_fin: TextureRect = $Sprite2D
@onready var texto_secreto: RichTextLabel = $RichTextLabel3
@onready var texto_reiniciar: RichTextLabel = $RichTextLabel5

var puede_reiniciar: bool = false
var tween_entrada: Tween
var tween_parpadeo: Tween

func _ready() -> void:
	get_tree().paused = false
	
	sprite_fin.pivot_offset_ratio = Vector2(0.5, 0.5)
	var escala_sprite: Vector2 = sprite_fin.scale
	sprite_fin.modulate.a = 0.0
	sprite_fin.scale = escala_sprite * 0.85
	
	texto_secreto.modulate.a = 0.0
	texto_reiniciar.modulate.a = 0.0
	
	var mostrar_secreto: bool = not Global.secreto
	if mostrar_secreto:
		texto_secreto.visible = true
		Global.secreto = true
	else:
		texto_secreto.visible = false
	tween_entrada = create_tween()
	
	tween_entrada.tween_property(sprite_fin, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween_entrada.parallel().tween_property(sprite_fin, "scale", escala_sprite, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if mostrar_secreto:
		tween_entrada.tween_property(texto_secreto, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

	tween_entrada.tween_property(texto_reiniciar, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE)
	tween_entrada.tween_callback(_iniciar_parpadeo)

func _iniciar_parpadeo() -> void:
	puede_reiniciar = true
	tween_parpadeo = create_tween().set_loops()
	tween_parpadeo.tween_property(texto_reiniciar, "modulate:a", 0.25, 0.8).set_trans(Tween.TRANS_SINE)
	tween_parpadeo.tween_property(texto_reiniciar, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)

func _input(event: InputEvent) -> void:
	if not puede_reiniciar:
		return
	
	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if tween_entrada:
			tween_entrada.kill()
		if tween_parpadeo:
			tween_parpadeo.kill()
		
		ControlGlobal.indice_nivel_actual = 0
		Global.muerto = false
		Global.locura = 0
		Global.locura_on = false
		Global.secreto_on = false
		get_tree().change_scene_to_file("res://Scenes/intro.tscn")
