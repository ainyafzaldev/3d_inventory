extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func startWalking():
	#$AnimationPlayer.stop(true)
	$AnimationPlayer.play("walking")

func stopWalking():
	#$AnimationPlayer.stop(true)
	$AnimationPlayer.play("idle")
