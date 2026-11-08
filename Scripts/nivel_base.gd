extends Node2D

@export var escena_jugador: PackedScene = preload("res://Scenes/jugador.tscn")
@export var escena_pan: PackedScene = preload("res://Scenes/pan_base.tscn")
@export var escena_mantequilla: PackedScene = preload("res://Scenes/pan_mantequilla.tscn")

@onready var objetos = $"objetos"
@onready var mapa: TileMapLayer = $mapa_base
@onready var mapa_obstaculos: TileMapLayer = $mapa_obstaculos
@export var posicion_inicial: Vector2i = Vector2i(0, 0)
@onready var camara: Camera2D = $Camera2D
@export var hambre_inicial = 15

var jugador_instancia: CharacterBody2D



	
@export var lista_objetos: Array = [
[Vector2i(3, 2), Global.TipoObjeto.PAN],
[Vector2i(4, 2), Global.TipoObjeto.PAN],
[Vector2i(5, 4), Global.TipoObjeto.PAN],
[Vector2i(8, 2), Global.TipoObjeto.PAN]
]
#Al hacer un nivel desde el editor, la segunda celda que hay que rellenar es el índice del objeto en el enum
#sigo escribiendo aquí que no me da, en el enum del global

#FUNCIONES PARA EL READY
func generar_objeto(vector: Vector2i, tipo):
	var objeto_instancia = null
	var script_especifico = null
	if tipo == Global.TipoObjeto.PAN:
		objeto_instancia = escena_pan.instantiate()#rellenar con cada tipo de objeto que se haga después
		script_especifico = preload("res://Scripts/pan_base.gd") #obtener la funcion que hace el objeto
		
	if tipo == Global.TipoObjeto.MANTEQUILLA:
		objeto_instancia = escena_mantequilla.instantiate()
		script_especifico = preload("res://Scripts/pan_mantequilla.gd") 
		
	if objeto_instancia:
		objeto_instancia.mapa = self
		objeto_instancia.pos_celda = vector #pasa las variables mapa y posición
		objetos.add_child(objeto_instancia)
		objeto_instancia.position = celda_a_posicion(vector) #Mueve el objeto a donde toca
		
		if script_especifico:
			objeto_instancia.set_script(script_especifico)  #le carga el script de su funcion especifica


func generar_objetos(list: Array):#Esto es el parsing de FP con otras palabras
	for array in list:
		generar_objeto(array[0], array[1])

func generar_jugador(pos):
	jugador_instancia = escena_jugador.instantiate()
	jugador_instancia.mapa = self
	add_child(jugador_instancia)
	jugador_instancia.position = celda_a_posicion(pos)
	
func _ready() -> void:
	Global.posicion_jugador = posicion_inicial
	Global.hambre = hambre_inicial
	generar_jugador(posicion_inicial)
	generar_objetos(lista_objetos)

	
func centrar_camara_en_puzle() -> void: #CAMARA, no sé muy bien lo que hace porque es chatgpetazo
	if not mapa or not camara:
		return

	# Obtiene el área que ocupan las baldosas en el mapa
	var rect_celdas: Rect2i = mapa.get_used_rect()
	var tamano_tile: Vector2i = mapa.tile_set.tile_size

	# Calcula las coordenadas del centro en píxeles del mundo
	var centro_x = (rect_celdas.position.x + (rect_celdas.size.x / 2.0)) * tamano_tile.x
	var centro_y = (rect_celdas.position.y + (rect_celdas.size.y / 2.0)) * tamano_tile.y

	camara.position = Vector2(centro_x, centro_y)

func celda_a_posicion(pos: Vector2i) -> Vector2: #transforma los datos de casilla a posición exacta
	if mapa:
		return mapa.map_to_local(pos)
	return Vector2 (0,0)

func es_transitable(pos: Vector2i) -> bool: #comprueba los dos tilemaps
	var datos_1: TileData = mapa.get_cell_tile_data(pos)
	var datos_2: TileData = mapa_obstaculos.get_cell_tile_data(pos)
	
	var suelo_valido = datos_1 != null and datos_1.get_custom_data("transitable")
	var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
	
	return suelo_valido and not es_bloqueado

func calcular_desliz(pos: Vector2i, apuntado: Vector2i) -> Vector2i:
	var res: Vector2i = pos
	while es_transitable(res + apuntado):
		res += apuntado
	return res
	
	

func es_meta(pos: Vector2i) -> bool:
	var datos: TileData = mapa_obstaculos.get_cell_tile_data(pos)
	var meta = datos != null and  datos.get_custom_data("meta")
	return meta

func terminar_nivel() -> void:
	if es_meta(Global.posicion_jugador):
		ControlGlobal.cargar_siguiente_nivel()
	
