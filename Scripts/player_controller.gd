extends CharacterBody2D

var mapa: Node2D 

@export var velocidad_suavizado: float = 15.0
@export var velocidad_desliz: float = 625.0
@export var altura_salto: float = 200.0
@export var duracion_salto: float = 0.8

const federico_on: Texture2D = preload("res://assets/sprites/federico_cargado.png")
const federico_goku: Texture2D = preload("res://assets/sprites/federico_cargado_ssj.png")

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}
var direccion_jugador: Vector2i
var deslizando: bool = false
var saltando: bool = false
var tirando: bool = false
var muriendo: bool = false
var derecha: bool = true
var lava: bool = false


func _ready() -> void:
	$AnimatedSprite2D.play("quieto_derecha")
	Global.locura = 0

func _process(delta: float) -> void:
	interactuar()
	apuntar()
	if mapa and not saltando:
		var celda_actual: Vector2i = mapa.posicion_a_celda(position)
		mapa.recoger_en(celda_actual)
		
		if mapa.es_lava(celda_actual) and z_index != 2:
			lava = true
		
		if deslizando and Global.efecto != Global.Efectos.MANTEQUILLA:
			Global.posicion_jugador = celda_actual
		
		var pos_destino: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
		
		if deslizando or Global.efecto == Global.Efectos.MANTEQUILLA:
			position = position.move_toward(pos_destino, velocidad_desliz * delta)
		elif Global.efecto == Global.Efectos.BASE or (Global.efecto == Global.Efectos.FEDERICO and Global.federico == Global.Federico.OFF):
			position = position.lerp(pos_destino, velocidad_suavizado * delta)
		elif Global.efecto == Global.Efectos.FEDERICO:
			position = position.move_toward(pos_destino, 0.6 * velocidad_desliz * delta)
		
		if position.distance_to(pos_destino) < 0.5:
			position = pos_destino
			deslizando = false
			tirando = false
			z_index = 0
			mapa.terminar_nivel()
			morir(Global.hambre, Global.posicion_jugador, Global.locura, mapa.locura_maxima)
			

func apuntar():
	if not deslizando and not saltando and not muriendo and not lava and not tirando:
		if Input.is_action_just_pressed("right"):
			direccion_jugador = direcciones.derecha
			$AnimatedSprite2D.play("quieto_derecha")
			derecha = true
			mover()
		elif Input.is_action_just_pressed("left"):
			direccion_jugador = direcciones.izquierda
			$AnimatedSprite2D.play("quieto_izquierda")
			derecha = false
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
	if mapa and (Global.hambre > 0 or Global.locura_on):
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
				var inicio: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
				Global.posicion_jugador += 4 * direccion_jugador
				var destino: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
				animar_federico_goku(inicio, destino)
				animar_salto(destino)
				Global.hambre -= 1
				print(Global.hambre)
				
			elif Global.federico == Global.Federico.OFF:
				Global.posicion_jugador += direccion_jugador
				Global.hambre -= 1
				print(Global.hambre)
				
			elif Global.federico == Global.Federico.ON:
				if mapa.es_transitable(Global.posicion_jugador + 2 * direccion_jugador):
					tirando = true
					y_sort_enabled = false
					z_index = 2
					Global.posicion_jugador += 2 * direccion_jugador
					animar_federico_on(mapa.celda_a_posicion(Global.posicion_jugador))
					Global.hambre -= 1
					print(Global.hambre)

func animar_salto(destino: Vector2) -> void:
	y_sort_enabled = false
	z_index = 2
	saltando = true
	var tween := create_tween()
	tween.tween_method(arco.bind(position, destino), 0.0, 1.0, duracion_salto)
	await tween.finished
	$AnimatedSprite2D.position.y = 0.0
	position = destino
	saltando = false
	y_sort_enabled = true
	z_index = 1

func arco(t: float, inicio: Vector2, destino: Vector2) -> void:
	position = inicio.lerp(destino, t)
	$AnimatedSprite2D.position.y = -4.0 * altura_salto * t * (1.0 - t)

func crear_sprite_federico(textura: Texture2D, pos: Vector2, prioridad_z: int) -> Sprite2D:
	var fede := Sprite2D.new()
	fede.texture = textura
	fede.position = pos
	fede.z_index = prioridad_z
	if direccion_jugador.x != 0:
		fede.flip_h = derecha
	fede.scale = Vector2.ZERO
	fede.modulate.a = 0.0
	mapa.add_child(fede)
	return fede

func animar_federico_on(destino: Vector2) -> void:
	var dir := Vector2(direccion_jugador)
	var pos_tiron: Vector2 = destino + dir * 10.0
	var pos_final_tiron: Vector2 = pos_tiron + dir * 8.0
	var fede := crear_sprite_federico(federico_on, pos_tiron, 4)
	
	var tween := create_tween()
	tween.tween_property(fede, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "modulate:a", 1.0, 0.1)
	tween.tween_property(fede, "position", pos_final_tiron, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "scale", Vector2(1.15, 0.88), 0.12)
	tween.tween_property(fede, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "modulate:a", 0.0, 0.15)
	tween.parallel().tween_property(fede, "position:y", pos_final_tiron.y - 8.0, 0.15)
	tween.tween_callback(fede.queue_free)

func animar_federico_goku(inicio: Vector2, destino: Vector2) -> void:
	var punto_medio: Vector2 = (inicio + destino) / 2.0
	var fede := crear_sprite_federico(federico_goku, punto_medio, 1)
	var tween := create_tween()
	tween.tween_property(fede, "scale", Vector2.ONE, duracion_salto * 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "modulate:a", 1.0, duracion_salto * 0.2)
	tween.tween_property(fede, "position:y", punto_medio.y + 10.0, duracion_salto * 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "scale", Vector2(1.22, 0.78), duracion_salto * 0.15)
	tween.tween_property(fede, "position:y", punto_medio.y - 6.0, duracion_salto * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "scale", Vector2.ZERO, duracion_salto * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "modulate:a", 0.0, duracion_salto * 0.35)
	tween.tween_callback(fede.queue_free)

func morir(hambre:int, pos: Vector2i, locura: int, locura_max):
	if muriendo:
		return 
	if hambre == 0 and not Global.locura_on or mapa.es_lava(pos) or locura >= locura_max:
		lava = false
		var lilbro = $AnimatedSprite2D
		muriendo = true
		if not derecha:
			lilbro.flip_h = true
		lilbro.play("muerto")
		var angulo_caida: float = -90.0 if direccion_jugador.x < 0 else 90.0
		var tween := create_tween()
		tween.tween_property(lilbro, "rotation_degrees", angulo_caida, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(lilbro, "position:y", 16.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		await tween.finished
		await get_tree().create_timer(1.5).timeout
		muriendo = false
		Global.muerto = true
