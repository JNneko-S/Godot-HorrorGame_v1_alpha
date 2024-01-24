class_name Interactable
extends Area3D
@onready var Objects = $Terrarian/Mountain3/Mountain12

@export var type : String = "???"

func action_use():
	queue_free()
