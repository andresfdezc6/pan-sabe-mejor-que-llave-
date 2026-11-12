extends "res://Scripts/recogible.gd"
@onready var textura_pulsado: Texture2D = preload("res://assets/sprites/key.png")

func _ready() -> void:
	super() 
	tipo = Global.TipoObjeto.BOTON

func aplicar_efecto() -> void:
	texture = textura_pulsado

func cambiar_casillas_cerradas() -> void:
	var capa: TileMapLayer = mapa.mapa_obstaculos
	
	for coords: Vector2i in capa.get_used_cells():
		var datos: TileData = capa.get_cell_tile_data(coords)
		if datos != null and datos.get_custom_data("cerrado"):
			if datos.get_custom_data("cerrado"):
				capa.set_cell(coords, 3, Vector2i(2, 2))
			else:
				capa.set_cell(coords, 3, Vector2i(2, 1))
