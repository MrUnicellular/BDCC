extends Node2D

var pawn
var id
var loc
var floorid

onready var move_tween = $MoveTween
onready var icon = $Icon
onready var icon_2 = $Icon2

func moveToPos(thePos:Vector2):
	move_tween.interpolate_property(self, "position",
			global_position, thePos + Vector2(RNG.randi_range(-16, 16), RNG.randi_range(-16, 16)), 0.5,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	move_tween.start()

func setPawnTexture(theText):
	if(theText == RoomStuff.PawnTexture.Fem):
		icon.texture = preload("res://Images/WorldPawns/fem.png")
	elif(theText == RoomStuff.PawnTexture.Masc):
		icon.texture = preload("res://Images/WorldPawns/masc.png")
	else:
		icon.texture = null

func setPawnActivityIcon(theIcon):
	if(theIcon == RoomStuff.PawnActivity.Chat):
		icon_2.texture = preload("res://Images/WorldPawnActivity/chat.png")
	elif(theIcon == RoomStuff.PawnActivity.Fight):
		icon_2.texture = preload("res://Images/WorldPawnActivity/fight.png")
	elif(theIcon == RoomStuff.PawnActivity.Sex):
		icon_2.texture = preload("res://Images/WorldPawnActivity/sex.png")
	else:
		icon_2.texture = null

func setPawnColor(theColor:Color):
	icon.self_modulate = theColor