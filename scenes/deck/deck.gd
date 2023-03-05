extends Node2D

# The root object of this PackedScene must have a init(int, int, bool) function.
@export var card_scene: PackedScene

var contents = []

func init():
	contents = default_deck()
	contents.shuffle()

# Called when the node enters the scene tree for the first time.
func _ready():
	init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func draw_card(flipped: bool):
	print("Drawing..")
	if contents.is_empty():
		return
	
	var data = index_to_card(contents.pop_back())
	
	var card = card_scene.instantiate()
	card.init(data[0], data[1], flipped)
	
	var x = self.global_position.x + randi_range(-180, 180)
	var y = self.global_position.y + randi_range(-150, 150)
	
	card.set_global_position(Vector2(x, y))
	
	get_parent().add_child(card)

static func index_to_card(index):
	var suit = index % 4
	var value = index % 13
	return [suit, value]

static func get_card_index(suit, value):
	var index = suit * 13 + value
	return index

static func default_deck():
	var deck = []
	
	for suit in 4:
		for face in 13:
			deck.push_back(get_card_index(suit, face))
	
	return deck


func _on_timer_timeout():
	draw_card(randi_range(0, 1) == 1)
