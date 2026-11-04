extends "res://Scripts/recogible.gd"

#Aquí se escribe el efecto de cada objeto
func aplicar_efecto() -> void:
	
	Global.hambre += 3
	print (Global.hambre)
