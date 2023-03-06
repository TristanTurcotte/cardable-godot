extends Node

const PORT = 4433

func _ready():
	# Started paused
	get_tree().paused = true
	# Save bandwidth by disabling server relay and peer notifs.
	multiplayer.server_relay = false
	
	# Start server in headless mode
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()

func _process(delta):
	var peer = multiplayer.multiplayer_peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Disconnected!")
		get_tree().paused = true
		$UI.show()

func _on_host_pressed():
	# Start as server
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILURE! WITH HOSTING")
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _on_connect_pressed():
	# Start as client
	var txt: String = $UI/Net/Options/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILURE!")
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	# Hide UI and unpause the game
	$UI.hide()
	get_tree().paused = false
	
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/multiplayer/test_world.tscn"))

func change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())

func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_select") and Input.is_action_just_pressed("ui_select"):
		change_level.call_deferred(load("res://scenes/multiplayer/test_world.tscn"))
