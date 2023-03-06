extends Node2D

# Generic card data
const SUITS = ["Hearts", "Diamonds", "Clubs", "Spades"]
const SUITS_LEN = 4
const VALUE_NAME = ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]
const VALUES_LEN = 13
const VALUE = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

# Represents which suit this card is, 0 = Hearts, 1 = Diamonds, 2 = Clubs, 3 = Spades
@export_enum("Hearts", "Diamonds", "Clubs", "Spades") var card_suit = 0
# Represents what this card's value index is (0-12)
@export_enum("Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King") var card_value = 0

var flipped = false
var deck_of_origin = null # Unused.

@onready var shape = self.find_child("CardShape")

# Initialize this card, set the suit, value, and if it is flipped or not.
# flip being true will mean the value will be facing down and you will see the card's back.
func init(suit, value, flip, deck = null):
	if flip:
		flip_card()
	
	if !set_card(suit, value):
		set_card(0, 0)
	
	if deck != null:
		deck_of_origin = deck # Currently unused, and it may be taking up some memory?

# Called when the node enters the scene tree for the first time.
func _ready():
	card_suit = randi_range(0, 3)
	card_value = randi_range(0, 12)
	print_debug("My shape is %s" % shape)
	shape.notify_texture_update()
	print_debug("We've got a(n) %s" % get_card_name())

# Flip the card
func flip_card():
	flipped = !flipped
	if shape != null:
		shape.notify_texture_update()
	print_debug("Flipping the card for it to be %s" % ("hidden" if flipped else "revealed"))

# Reveals the card, if the card was already revealed it won't do anything.
func reveal_card():
	if !flipped:
		return
	self.flip_card()

# Hides the card, if the card was already revealed it won't do anything.
func hide_card():
	if flipped:
		return
	self.flip_card()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func randomize_card():
	card_suit = randi_range(0, 3)
	card_value = randi_range(0, 12)
	if shape != null:
		shape.notify_texture_update()

# Returns a String representation of this card's suit & value.
func get_card_name() -> String:
	var suit = str(SUITS[self.card_suit])
	var value = str(VALUE_NAME[self.card_value])
	return "%s of %s" % [value, suit]

func get_suit_name() -> String:
	return SUITS[self.card_suit]

# Gets this card's suit index.
# 0 = Hearts
# 1 = Diamonds
# 2 = Clubs
# 3 = Spades
func get_suit_index() -> int:
	return self.card_suit

# Gets the name of the card, written out.
# e.g. "Ace", or "Three", "Jack"
func get_value_name() -> String:
	return VALUE_NAME[self.card_value]

# Gets this card's value index.
# 0 = Ace, 1 = Two, ...
# 8 = Nine, 9 = Ten, ..
# 12 = King
func get_value_index() -> int:
	return self.card_value

func set_card(suit_index, value_index) -> bool:
	if suit_index >= SUITS_LEN || suit_index < 0 || value_index >= VALUES_LEN || value_index < 0:
		print_debug("ERROR: Invalud suit=%s or value=%s index" % [suit_index, value_index])
		return false
	self.card_suit = suit_index
	self.card_value = value_index
	if shape != null:
		shape.notify_texture_update()
	return true

func _on_timer_timeout():
	var val = randi_range(0,100)
	if val > 80:
		flip_card()
	elif val < 10:
		randomize_card()
