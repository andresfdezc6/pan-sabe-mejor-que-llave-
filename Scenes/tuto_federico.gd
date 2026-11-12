extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	var hud_texto := get_node_or_null("../RichTextLabel")
	var hud_indicador := get_node_or_null("../indicador_objeto")
	if hud_texto:
		hud_texto.visible = false
	if hud_indicador:
		hud_indicador.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		var hud_texto := get_node_or_null("../RichTextLabel")
		var hud_indicador := get_node_or_null("../indicador_objeto")
		if hud_texto:
			hud_texto.visible = true
		if hud_indicador:
			hud_indicador.visible = true
			
		get_tree().paused = false
		queue_free()
