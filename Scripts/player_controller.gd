extends CharacterBody2D

var mapa: Node2D 

@export var velocidad_suavizado: float = 15.0
@export var velocidad_desliz: float = 150.0
@export var altura_salto: float = 20.0
@export var duracion_salto: float = 0.8

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}
var direccion_jugador: Vector2i
var deslizando: bool = false
var saltando: bool = false

func _process(delta: float) -> void:
	interactuar()
	apuntar()
	if mapa:
		var pos_destino = mapa.celda_a_posicion(Global.posicion_jugador)
		
		if Global.efecto == Global.Efectos.BASE or (Global.efecto == Global.Efectos.FEDERICO and Global.federico == Global.Federico.OFF):
			position = position.lerp(pos_destino, velocidad_suavizado * delta)
			
		elif Global.efecto == Global.Efectos.MANTEQUILLA:
			position = position.move_toward(pos_destino, velocidad_desliz * delta)
			
		elif Global.efecto == Global.Efectos.FEDERICO:
			position = position.move_toward(pos_destino, 0.6*velocidad_desliz * delta)
		
		mapa.recoger_en(mapa.posicion_a_celda(position))
		
		if position.distance_to(pos_destino) < 0.5:
			position = pos_destino
			deslizando = false
			mapa.terminar_nivel()

func apuntar():
	if not deslizando and not saltando:
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

func interactuar():
	if Global.efecto == Global.Efectos.FEDERICO:
		if Input.is_action_just_pressed("interactuar"):
			if Global.federico == Global.Federico.OFF:
				Global.federico = Global.Federico.ON
				print("ON")
			elif Global.federico == Global.Federico.ON:
				Global.federico = Global.Federico.GOKU
				print("GOKU")
			elif Global.federico == Global.Federico.GOKU:
				Global.federico = Global.Federico.OFF
				print("OFF")

func mover():
	if mapa and Global.hambre > 1:
		if Global.efecto == Global.Efectos.BASE:
			if mapa.es_transitable(Global.posicion_jugador + direccion_jugador):
				Global.posicion_jugador += direccion_jugador
				Global.hambre -= 1
				print(Global.hambre)
		elif Global.efecto == Global.Efectos.MANTEQUILLA:
			if mapa.es_transitable(Global.posicion_jugador + direccion_jugador):
				Global.posicion_jugador = mapa.calcular_desliz(Global.posicion_jugador, direccion_jugador)
				deslizando = true
				Global.hambre -= 1
				print(Global.hambre)
		elif Global.efecto == Global.Efectos.FEDERICO and mapa.es_saltable(Global.posicion_jugador, direccion_jugador):
			if Global.federico == Global.Federico.GOKU:
				Global.posicion_jugador = Global.posicion_jugador + 4 * direccion_jugador
				animar_salto(mapa.celda_a_posicion(Global.posicion_jugador))
				Global.hambre -= 1
				print(Global.hambre)
			elif Global.federico == Global.Federico.OFF:
				Global.posicion_jugador += direccion_jugador
				Global.hambre -= 1
				print(Global.hambre)
			elif Global.federico == Global.Federico.ON:
				if mapa.es_transitable(Global.posicion_jugador + 2*direccion_jugador):
					Global.posicion_jugador += 2 * direccion_jugador
					Global.hambre -= 1
					print(Global.hambre)

func animar_salto(destino: Vector2) -> void:
	saltando = true
	var tween := create_tween()
	tween.tween_method(_arco.bind(position, destino), 0.0, 1.0, duracion_salto)
	await tween.finished
	$AnimatedSprite2D.position.y = 0.0
	position = destino
	saltando = false

func _arco(t: float, inicio: Vector2, destino: Vector2) -> void:
	position = inicio.lerp(destino, t)
	$AnimatedSprite2D.position.y = -4.0 * altura_salto * t * (1.0 - t)
