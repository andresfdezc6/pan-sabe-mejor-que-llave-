extends CharacterBody2D

var mapa: Node2D 

@export var velocidad_suavizado: float = 15.0
@export var velocidad_desliz: float = 150.0

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}
var direccion_jugador: Vector2i
var deslizando: bool = false

func _process(delta: float) -> void:
	apuntar()
	if mapa:
		var pos_destino = mapa.celda_a_posicion(Global.posicion_jugador)
		
		if Global.efecto == Global.Efectos.BASE:
			position = position.lerp(pos_destino, velocidad_suavizado * delta)
			
		elif Global.efecto == Global.Efectos.MANTEQUILLA:
			position = position.move_toward(pos_destino, velocidad_desliz * delta)
		
		mapa.recoger_en(mapa.posicion_a_celda(position))
		
		if position.distance_to(pos_destino) < 0.5:
			position = pos_destino
			deslizando = false
			mapa.terminar_nivel()

func apuntar():
	if not deslizando:
		if Input.is_action_just_pressed("right"):
			direccion_jugador = direcciones.derecha
			mover()
		elif Input.is_action_just_pressed("left"):
			direccion_jugador = direcciones.izquierda
			mover()
		elif Input.is_action_just_pressed("up"):
			direccion_jugador = direcciones.arriba
			mover()
		elif Input.is_action_just_pressed("down"):
			direccion_jugador = direcciones.abajo
			mover()

func mover():
	if mapa and mapa.es_transitable(Global.posicion_jugador + direccion_jugador) and Global.hambre > 1:
		if Global.efecto == Global.Efectos.BASE:
			Global.posicion_jugador += direccion_jugador
		elif Global.efecto == Global.Efectos.MANTEQUILLA:
			Global.posicion_jugador = mapa.calcular_desliz(Global.posicion_jugador, direccion_jugador)
			deslizando = true
		Global.hambre -= 1
		print(Global.hambre)
