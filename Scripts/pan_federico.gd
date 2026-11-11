extends "res://Scripts/recogible.gd"

func aplicar_efecto() -> void:
	Global.efecto = Global.Efectos.FEDERICO
	Global.federico = Global.Federico.OFF
	Global.hambre += 3
	print (Global.hambre)
