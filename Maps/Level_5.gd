extends Node

var TotalCollectedKeys := 0 #鍵の合計取得数
var keys2Fin := 1

func _ready():
	keys2Fin = $Keys.get_children().size()
	$GUIKeysContainer/LabelTotalKeys.text = str($Keys.get_children().size())
	
	for key in $Keys.get_children():
		key.connect("collectedKey",keyCollected)
		

func keyCollected():
	TotalCollectedKeys += 1
	$GUIKeysContainer/LabelCurrentKeys.text = str(TotalCollectedKeys)
	$collectedSound.play()
	print(str(keys2Fin))
	if TotalCollectedKeys >= keys2Fin:
		get_tree().change_scene_to_file("res://final_level.tscn")
