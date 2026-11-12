extends "res://Scripts/recogible.gd"

const tuto_fede: PackedScene = preload("res://Scenes/tuto_federico.tscn")

func aplicar_efecto() -> void:
	super.aplicar_efecto() # O la línea con la que sumes el hambre
	Global.efecto = Global.Efectos.FEDERICO
	Global.federico = Global.Federico.OFF

	if not Global.tuto_federico_visto:
		Global.tuto_federico_visto = true
		var tuto := tuto_fede.instantiate()
		mapa.get_node("CanvasLayer").add_child(tuto)
