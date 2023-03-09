extends Node2D
class_name Deck
# The root object of this PackedScene must have a init(int, int, bool) function.
@export var card_scene: PackedScene = preload("res://scenes/playing_card/playing_card.tscn")

var init_deck = []

var contents = []
var cards_out_in_the_world = []

func init():
	set_contents(Deck.default_deck())
	contents.shuffle()

# Sets the content of this deck
func set_contents(content):
	contents = content
	init_deck = [] + content

# Called when the node enters the scene tree for the first time.
func _ready():
	init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

### Deck interaction functions ###

# Draw a card, flipped or not. The card is randomly thrown.
func draw_card(flipped: bool = false):
	if contents.is_empty():
		return
	
	var data = Deck.index_to_card(contents.pop_back())
	
	var card = card_scene.instantiate()
	card.init(data[0], data[1], flipped, self)
	####
	get_tree().call_group("label", "update_dat_label", "%s" % card.get_card_name())
	
	####
	
	var x = self.global_position.x + randi_range(-400, 400)
	var y = self.global_position.y + randi_range(-220, 220)
	
	card.set_global_position(Vector2(x, y))
	
	get_parent().add_child(card, true)
	cards_out_in_the_world.push_back(card) # Add the card to our own list of cards that exist. Doing this the Godot way would probably be to create a Group for each deck that cards would be added to send a signal to.

# Shuffle the deck. If `retrieve_cards` is false, just shuffle what we've got. If
# it is true, retrieve all of the cards that are in the world that came from this
# deck and then shuffle.
func shuffle_deck(retrieve_cards: bool = false):
	if retrieve_cards && !cards_out_in_the_world.is_empty():
		for i in cards_out_in_the_world.size():
			var card = cards_out_in_the_world.pop_front()
			var index = Deck.get_card_index(card.get_suit_index(), card.get_value_index())
			contents.push_back(index)
			card.queue_free()
	
	contents.shuffle()

# Similar to shuffle_deck, except it fully replenishes the deck without retrieving
# already drawn cards, and then shuffles.
func reset_deck():
	contents = [] + init_deck
	contents.shuffle()

# Can be useful if reset_deck() was used but the user wants to now clear the board
# but not re-collect the cards. Collects all cards that were dealt from this deck
# and discards them into the void.
func retrieve_but_discard():
	if cards_out_in_the_world.is_empty():
		return
	for i in cards_out_in_the_world.size():
		var card = cards_out_in_the_world.pop_front()
		card.queue_free()

func cards_left() -> int:
	return self.contents.size()


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
			deck.push_back(Deck.get_card_index(suit, face))
	
	return deck

func _on_timer_timeout():
	if cards_left() > 0:
		draw_card(randi_range(0, 3) == 1)
	else:
		shuffle_deck(true)


func _on_delay_timer_timeout():
	$SpawnTimer.start()
