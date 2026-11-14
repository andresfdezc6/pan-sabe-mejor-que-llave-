extends "res://Scripts/recogible.gd"


func aplicar_efecto() -> void:
	if mapa.scene_file_path == "res://Scenes/nivel_8.tscn":
		abrir_y_generar_secreto()
	elif not Global.secreto_on:
		get_tree().change_scene_to_file("res://Scenes/final_malo.tscn")
	else:
		cambiar_casillas_cerradas()

func cambiar_casillas_cerradas() -> void:
	var capa: TileMapLayer = mapa.mapa_obstaculos
	
	for coords: Vector2i in capa.get_used_cells():
		var datos: TileData = capa.get_cell_tile_data(coords)
		if datos != null and datos.get_custom_data("secreta"):
			if datos.get_custom_data("abajo"):
				capa.set_cell(coords, 7, Vector2i(2, 2))
			else:
				capa.set_cell(coords, 7, Vector2i(2, 1))

func abrir_y_generar_secreto() -> void:
	var capa: TileMapLayer = mapa.mapa_obstaculos
	
	for coords: Vector2i in capa.get_used_cells():
		var datos: TileData = capa.get_cell_tile_data(coords)
		if datos != null and datos.get_custom_data("secreta"):
			if datos.get_custom_data("abajo"):
				capa.set_cell(coords, 7, Vector2i(2, 2))
				mapa.celda_puerta_secreta = coords
				mapa.generar_objeto(coords, Global.TipoObjeto.SECRETO)
			else:
				capa.set_cell(coords, 7, Vector2i(2, 1))
