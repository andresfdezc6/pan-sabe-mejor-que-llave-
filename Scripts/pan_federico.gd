extends "res://Scripts/recogible.gd"

func aplicar_efecto() -> void:
	Global.efecto = Global.Efectos.FEDERICO
	Global.hambre += 3
	print (Global.hambre)
