extends Node2D
@onready var mapa: TileMapLayer = $mapa_base
@onready var mapa_decorativo: TileMapLayer = $mapa_decorativo
@export var posicion_inicial = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.posicion_jugador = posicion_inicial
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func es_transitable(pos: Vector2i) -> bool:
	var datos_1: TileData = mapa.get_cell_tile_data(pos)
	var datos_2: TileData = mapa_decorativo.get_cell_tile_data(pos)
	var suelo_valido = datos_1 != null and datos_1.get_custom_data("transitable")
	var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
	return suelo_valido and not es_bloqueado

@export var mostrar_cuadricula: bool = true
@export var color_lineas: Color = Color(1, 1, 1, 0.35) # Blanco semi-transparente

func _draw() -> void: #dibujar cuadrícula
	if not mostrar_cuadricula or not mapa or not mapa.tile_set:
		return
	
	var tamano_celda = Vector2(mapa.tile_set.tile_size)
	var area_usada = mapa.get_used_rect() # Obtiene los límites pintados del mapa

	# Recorre todas las casillas pintadas y dibuja su contorno
	for x in range(area_usada.position.x, area_usada.end.x):
		for y in range(area_usada.position.y, area_usada.end.y):
			var centro_celda = mapa.map_to_local(Vector2i(x, y))
			var esquina_superior_izq = centro_celda - (tamano_celda / 2.0)
			
			# Dibuja un rectángulo sin relleno de 1 píxel de grosor
			draw_rect(Rect2(esquina_superior_izq, tamano_celda), color_lineas, false, 1.0)
	
