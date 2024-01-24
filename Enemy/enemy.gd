extends CharacterBody3D
@onready var nav_agent : NavigationAgent3D = $NavAgent

var speed := 2.2 #速度
var navRange := 50 #ナビゲーションの範囲
var target_location : Vector3 #ターゲットの場所

enum STATES {Roam, Chase} #状態。{徘徊,追跡}の二つ
var currentState = STATES.Roam #状態のスイッチ。Roamの状態から始まる。
var player : Player

var lookAtVar = Vector3.ZERO


func _ready(): #ready関数では変数をランダム化し、関数を実装する。
	randomize()
	await get_tree().physics_frame
	get_roam_location() #位置から取得
	

func get_roam_location(): #この関数はVector3型の次のlocation変数を作成し、次の場所へ動く。
	var nextLocation = Vector3.ZERO
	#部屋の位置を取得するついでに部屋の位置へ行くことが可能かどうかもチェックする
	while nextLocation == Vector3.ZERO:
		nextLocation = await roamLocation()
		print("次の場所を試してください",nextLocation)
		
	
func roamLocation() -> Vector3:
	await get_tree().process_frame
	var origPos = global_position
	target_location = Vector3(origPos.x+(navRange * randf_range(-1.0,1.0)), 
								origPos.y,
								origPos.z+(navRange * randf_range(-1.0,1.0))) #ここが敵の捜索場所で範囲内の位置の周囲で、ターゲットの場所として一つの点を選択。
	nav_agent.set_target_position(target_location)
	#print(target_location,"は目的の場所へ経路探索できるのか？",nav_agent.is_target_reachable())
	#ナビの参照を取得し、ターゲット位置を設定する
	
	if nav_agent.is_target_reachable():
		return target_location #到達できる時はランダムなポイントを選択
	else:
		return Vector3.ZERO #無理な時はVector3を返す

	
func _physics_process(_delta):
	if currentState == STATES.Roam:
		if nav_agent.is_target_reachable() and not nav_agent.is_target_reached():
			var next_location = nav_agent.get_next_path_position() #次のパス位置を返す関数
			velocity = global_position.direction_to(next_location) * speed
			if !is_on_floor():
				velocity.y -= 10
			move_and_slide()
			lookAtVar = lookAtVar.lerp(Vector3(next_location.x, 0, next_location.z), .1)
			look_at(lookAtVar)
			rotation.x = 0
		else:
			print("ターゲットが到達可能か？")
			get_roam_location()

	if currentState == STATES.Chase:
		velocity = global_position.direction_to(player.global_position) * speed * 1.2
		lookAtVar = lookAtVar.lerp(Vector3(player.global_position.x,0,player.global_position.y),.1)
		look_at(lookAtVar)
		if !is_on_floor():
			velocity.y -= 10
		move_and_slide()



func _on_kill_player_body_entered(body):
	if body is Player:
		get_tree().change_scene_to_file("res://Maps/kill_scene.tscn")
	pass

func _on_timer_2_roam_timeout():
	print("State now is Roam ")
	currentState = STATES.Roam


func _on_detect_player_body_entered(body):
	if body is Player:
		print("Player detected")
		currentState = STATES.Chase
		player = body
		$Timer2Roam.start()
		
