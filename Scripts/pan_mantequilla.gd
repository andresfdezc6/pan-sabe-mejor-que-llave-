extends "res://Scripts/recogible.gd"

func aplicar_efecto() -> void:
	Global.efecto = Global.Efectos.MANTEQUILLA
	Global.hambre += 5
	print (Global.hambre)
