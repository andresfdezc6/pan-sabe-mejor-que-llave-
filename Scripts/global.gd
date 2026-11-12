extends Node

var posicion_jugador: Vector2i
var hambre: int
enum TipoObjeto {PAN, MANTEQUILLA, FEDERICO, BOTON, PANCONPAN}
enum Efectos {BASE, MANTEQUILLA, FEDERICO, PANCONPAN}
enum Federico {OFF, ON, GOKU}
var federico: Federico
var efecto: Efectos
var muerto: bool
var locura: int
