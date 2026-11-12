extends "res://Scripts/recogible.gd"


func aplicar_efecto() -> void:
	Global.hambre += 3
	Global.efecto = Global.Efectos.PANCONPAN
