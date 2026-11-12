extends Node2D

#importado de escenas para instanciar objetos
@export var escena_jugador: PackedScene = preload("res://Scenes/jugador.tscn")
@export var escena_pan: PackedScene = preload("res://Scenes/pan_base.tscn")
@export var escena_mantequilla: PackedScene = preload("res://Scenes/pan_mantequilla.tscn")
@export var escena_federico: PackedScene = preload("res://Scenes/pan_federico.tscn")
@export var escena_boton: PackedScene = preload("res://Scenes/boton.tscn")

#importado de escenas ya existentes
@onready var objetos = $"objetos"
@onready var mapa: TileMapLayer = $mapa_base
@onready var mapa_obstaculos: TileMapLayer = $mapa_obstaculos
@onready var camara: Camera2D = $Camera2D
@onready var texto: RichTextLabel = $RichTextLabel
@onready var jugador_instancia: CharacterBody2D

#declarado de cosas específicas de cada nivel (editar en el inspector)
@export var posicion_inicial: Vector2i = Vector2i(0, 0)
@export var hambre_inicial = 15
@export var zoom: float
@export var lista_objetos: Array = []

#para la lógica de recoger objetos
var objetos_en_celda: Dictionary = {}

#funciones para el ready
func generar_objeto(vector: Vector2i, tipo):
	var objeto_instancia = null
	var script_especifico = null
	
	if tipo == Global.TipoObjeto.PAN:
		objeto_instancia = escena_pan.instantiate()#rellenar con cada tipo de objeto que se haga después
		script_especifico = preload("res://Scripts/pan_base.gd") #obtener la funcion que hace el objeto
		
	if tipo == Global.TipoObjeto.MANTEQUILLA:
		objeto_instancia = escena_mantequilla.instantiate()
		script_especifico = preload("res://Scripts/pan_mantequilla.gd") 

	if tipo == Global.TipoObjeto.FEDERICO:
		objeto_instancia = escena_federico.instantiate()
		script_especifico = preload("res://Scripts/pan_federico.gd") 
		
	if tipo == Global.TipoObjeto.BOTON:
		objeto_instancia = escena_boton.instantiate()
		script_especifico = preload("res://Scripts/boton.gd")
		
	if objeto_instancia:
		objeto_instancia.mapa = self
		objeto_instancia.pos_celda = vector #pasa las variables mapa y posición
		objetos.add_child(objeto_instancia)
		objeto_instancia.position = celda_a_posicion(vector) #Mueve el objeto a donde toca
		
		if script_especifico:
			objeto_instancia.set_script(script_especifico)  #le carga el script de su funcion especifica
		objetos_en_celda[vector] = objeto_instancia

func generar_objetos(list: Array):#Esto es el parsing de FP con otras palabras
	for array in list:
		generar_objeto(array[0], array[1])

func generar_jugador(pos):
	jugador_instancia = escena_jugador.instantiate()
	jugador_instancia.mapa = self
	add_child(jugador_instancia)
	jugador_instancia.position = celda_a_posicion(pos)

#establece las variables globales a las específicas del nivel y genera al jugador y objetos
func _ready() -> void:
	centrar_camara_en_puzle(zoom)
	Global.posicion_jugador = posicion_inicial
	Global.hambre = hambre_inicial
	Global.efecto = Global.Efectos.BASE
	generar_jugador(posicion_inicial)
	generar_objetos(lista_objetos)

func _process(float) ->void:
	texto.text = "Hambre: " + str(Global.hambre)

#CAMARA, no sé muy bien lo que hace porque es chatgpetazo
func centrar_camara_en_puzle(zoom:float) -> void: 
	if not mapa_obstaculos or not camara:
		return

	# Obtiene el área que ocupan las baldosas en el mapa
	var rect_celdas: Rect2i = mapa.get_used_rect()
	rect_celdas = rect_celdas.merge(mapa_obstaculos.get_used_rect())
	var tamano_tile: Vector2i = mapa.tile_set.tile_size

	# Calcula las coordenadas del centro en píxeles del mundo
	var centro_x = (rect_celdas.position.x + (rect_celdas.size.x / 2.0)) * tamano_tile.x
	var centro_y = (rect_celdas.position.y + (rect_celdas.size.y / 2.0)) * tamano_tile.y

	camara.position = Vector2(centro_x, centro_y)
	camara.zoom = Vector2(zoom, zoom)

#transforma los datos de casilla a posición exacta
func celda_a_posicion(pos: Vector2i) -> Vector2:
	if mapa:
		return mapa.map_to_local(pos)
	return Vector2 (0,0)

#la contraria
func posicion_a_celda(pos: Vector2) -> Vector2i:
	if mapa:
		return mapa.local_to_map(pos)  
	return Vector2i(0,0)

#comprueba si hay un objeto en la celda y aplica su efecto
func recoger_en(celda: Vector2i) -> void:
	if objetos_en_celda.has(celda):
		var objeto = objetos_en_celda[celda]
		objetos_en_celda.erase(celda)
		objeto.aplicar_efecto()
		if not objeto.tipo == Global.TipoObjeto.BOTON:
			objeto.queue_free()

#comprueba los dos tilemaps y devuelve si la casilla es transitable
func es_transitable(pos: Vector2i) -> bool: 
	var datos_1: TileData = mapa.get_cell_tile_data(pos)
	var datos_2: TileData = mapa_obstaculos.get_cell_tile_data(pos)
	
	var suelo_valido = datos_1 != null and datos_1.get_custom_data("transitable")
	var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
	
	return suelo_valido and not es_bloqueado

func es_saltable(pos:Vector2i, dir:Vector2i):
	if Global.federico == Global.Federico.GOKU:
		if not(es_transitable(pos + 4*dir) and es_transitable(pos + 2*dir)):
			print("no se puede saltar, no hay suelo")
			return false
		for x in range(0, 5):
			var datos_2: TileData = mapa_obstaculos.get_cell_tile_data(pos + x*dir)
			var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
			if es_bloqueado:
				print("no se puede saltar, está bloqueado")
				return false
		print("se puede saltar")
	elif Global.federico == Global.Federico.ON:
		var datos_2: TileData = mapa_obstaculos.get_cell_tile_data(pos + dir)
		var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
		if not(es_transitable(pos + 2*dir)):
			print("no se puede saltar, no hay suelo")
			return false
		if es_bloqueado:
			print("no se puede saltar, está bloqueado")
			return false
	elif Global.federico == Global.Federico.OFF:
		return es_transitable(pos + dir)
	return true
		
		
#calcula hasta donde se puede deslizar y lo devuelve como vector
func calcular_desliz(pos: Vector2i, apuntado: Vector2i) -> Vector2i:
	var res: Vector2i = pos
	while es_transitable(res + apuntado):
		res += apuntado
	return res

#comprueba si una casilla es la meta
func es_meta(pos: Vector2i) -> bool:
	var datos: TileData = mapa_obstaculos.get_cell_tile_data(pos)
	var meta = datos != null and  datos.get_custom_data("meta")
	return meta

#si la casilla es meta, invoca a control para cambiar de nivel
func terminar_nivel() -> void:
	if es_meta(Global.posicion_jugador):
		ControlGlobal.cargar_siguiente_nivel()
