extends RichTextLabel

func _ready() -> void:
	if Global.secreto_on:
		text = "ELIGE: ¿PAN Y LLAVE?"
	else:
		text = "ELIGE: ¿PAN O LLAVE?"
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)
