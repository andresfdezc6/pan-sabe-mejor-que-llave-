extends "res://Scripts/recogible.gd"

#Aquí se escribe el efecto de cada objeto
func aplicar_efecto() -> void:
	Global.efecto = Global.Efectos.MANTEQUILLA
	Global.hambre += 5
	print (Global.hambre)
