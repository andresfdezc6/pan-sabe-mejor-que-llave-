extends "res://Scripts/recogible.gd"
func _ready() -> void:
	z_index = 8
func _process(delta:float) -> void:
	pass
# Called when the node enters the scene tree for the first time.
func aplicar_efecto() -> void:
	Global.secreto_on = true
