extends "res://Scripts/recogible.gd"


func aplicar_efecto() -> void:
	Global.hambre += 3
	Global.locura_on = true
