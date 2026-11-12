extends Node

var posicion_jugador: Vector2i
var hambre: int
enum TipoObjeto {PAN, MANTEQUILLA, FEDERICO, BOTON}
enum Efectos {BASE, MANTEQUILLA, FEDERICO}
enum Federico {OFF, ON, GOKU}
var federico: Federico
var efecto: Efectos
