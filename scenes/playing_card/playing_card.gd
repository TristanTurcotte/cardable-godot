extends Node2D

class_name PlayingCard

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

# When false, the card is face up. When true, it is face down.
@export var flipped = false

@onready var shape = self.find_child("MeshInstance2D")

# Initialize this card, set the suit, value, and if it is flipped or not.
# flip being true will mean the value will be facing down and you will see the card's back.
func init(suit, value, flip, _deck = null):
	if flip:
		flip_card()
	
	if !set_card(suit, value):
		set_card(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.notify_texture_update()
	self.update_texture()
	print_debug("Who am i? %s, %s, %s.\n%s" % [OS.get_unique_id(), OS.get_process_id(), OS.get_main_thread_id(), textures])

# Flip the card
func flip_card():
	self.flipped = !self.flipped
	self.notify_texture_update()

# Reveals the card, if the card was already revealed it won't do anything.
func reveal_card():
	if !self.flipped:
		return
	self.flip_card()

# Hides the card, if the card was already revealed it won't do anything.
func hide_card():
	if self.flipped:
		return
	self.flip_card()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.update_texture_flag:
		self.update_texture()
		print_debug("PROCESS: updating texture!")

func randomize_card():
	self.card_suit = randi_range(0, 3)
	self.card_value = randi_range(0, 12)
	self.notify_texture_update()

# Returns a String representation of this card's suit & value.
func get_card_name() -> String:
	var suit = str(PlayingCard.SUITS[self.card_suit])
	var value = str(PlayingCard.VALUE_NAME[self.card_value])
	return "%s of %s" % [value, suit]

func get_suit_name() -> String:
	return PlayingCard.SUITS[self.card_suit]

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
	return PlayingCard.VALUE_NAME[self.card_value]

# Gets this card's value index.
# 0 = Ace, 1 = Two, ...
# 8 = Nine, 9 = Ten, ..
# 12 = King
func get_value_index() -> int:
	return self.card_value

func get_flipped():
	return self.flipped

func set_card(suit_index, value_index) -> bool:
	if suit_index >= PlayingCard.SUITS_LEN || suit_index < 0 || value_index >= PlayingCard.VALUES_LEN || value_index < 0:
		print_debug("ERROR: Invalid suit=%s or value=%s index" % [suit_index, value_index])
		return false
	self.card_suit = suit_index
	self.card_value = value_index
	self.set_meta("card_face_index", self.get_suit_index() * 13 + self.get_value_index())
	self.notify_texture_update()
	return true

### TEXTURE CODE ###


const textures = [preload("res://resources/cards/00_00.png"), preload("res://resources/cards/00_01.png"), preload("res://resources/cards/00_02.png"), preload("res://resources/cards/00_03.png"), preload("res://resources/cards/00_04.png"), preload("res://resources/cards/00_05.png"), preload("res://resources/cards/00_06.png"), preload("res://resources/cards/00_07.png"), preload("res://resources/cards/00_08.png"), preload("res://resources/cards/00_09.png"), preload("res://resources/cards/00_10.png"), preload("res://resources/cards/00_11.png"), preload("res://resources/cards/00_12.png"),
				preload("res://resources/cards/01_00.png"), preload("res://resources/cards/01_01.png"), preload("res://resources/cards/01_02.png"), preload("res://resources/cards/01_03.png"), preload("res://resources/cards/01_04.png"), preload("res://resources/cards/01_05.png"), preload("res://resources/cards/01_06.png"), preload("res://resources/cards/01_07.png"), preload("res://resources/cards/01_08.png"), preload("res://resources/cards/01_09.png"), preload("res://resources/cards/01_10.png"), preload("res://resources/cards/01_11.png"), preload("res://resources/cards/01_12.png"),
				preload("res://resources/cards/02_00.png"), preload("res://resources/cards/02_01.png"), preload("res://resources/cards/02_02.png"), preload("res://resources/cards/02_03.png"), preload("res://resources/cards/02_04.png"), preload("res://resources/cards/02_05.png"), preload("res://resources/cards/02_06.png"), preload("res://resources/cards/02_07.png"), preload("res://resources/cards/02_08.png"), preload("res://resources/cards/02_09.png"), preload("res://resources/cards/02_10.png"), preload("res://resources/cards/02_11.png"), preload("res://resources/cards/02_12.png"),
				preload("res://resources/cards/03_00.png"), preload("res://resources/cards/03_01.png"), preload("res://resources/cards/03_02.png"), preload("res://resources/cards/03_03.png"), preload("res://resources/cards/03_04.png"), preload("res://resources/cards/03_05.png"), preload("res://resources/cards/03_06.png"), preload("res://resources/cards/03_07.png"), preload("res://resources/cards/03_08.png"), preload("res://resources/cards/03_09.png"), preload("res://resources/cards/03_10.png"), preload("res://resources/cards/03_11.png"), preload("res://resources/cards/03_12.png")]
const back_texture = preload("res://resources/cards/Card_back_01.svg.png")

# Flag indicating if the texture was changed & needs updating
var update_texture_flag = false

# Returns the texture data that coorisponds with this card's suit & value.
func get_card_texture() -> Resource:
	if !self.get_flipped():
		var index = self.get_suit_index() * 13 + self.get_value_index()
		if index >= PlayingCard.textures.size():
			print_debug("ERROR: texture index too big %s. suit = %s, value = %s" % [index, card_suit, card_value])
			return PlayingCard.textures[0]
		return PlayingCard.textures[index]
	else: # To get the back texture
		return PlayingCard.back_texture

# Call this whenever the value of the card should change, will automatically
# update the object's texture on _ready() or on _process(delta).
func notify_texture_update():
	self.update_texture_flag = true

# Retrieves the texture that matches this card's suit/value and set's this
# mesh's texture to the retrieved value
func update_texture():
	var text = get_card_texture() # Set the card's texture based off of it's initial value
	##### was testing to see if the card texture would be visible in multiplayer with this, made no difference
	#var filename = "res://resources/cards/"
	#var suit = get_suit_index()
	#var val = get_value_index()
	#filename += "0" + str(suit) + "_"
	#if val <= 9:
	#	filename += "0" + str(val) + ".png"
	#else:
	#	filename += str(val) + ".png"
	
	#####
	$MeshInstance2D.set_texture(text)
	self.update_texture_flag = false

