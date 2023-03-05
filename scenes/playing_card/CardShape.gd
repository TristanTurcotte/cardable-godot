extends MeshInstance2D

const textures = [preload("res://resources/cards/00_00.png"), preload("res://resources/cards/00_01.png"), preload("res://resources/cards/00_02.png"), preload("res://resources/cards/00_03.png"), preload("res://resources/cards/00_04.png"), preload("res://resources/cards/00_05.png"), preload("res://resources/cards/00_06.png"), preload("res://resources/cards/00_07.png"), preload("res://resources/cards/00_08.png"), preload("res://resources/cards/00_09.png"), preload("res://resources/cards/00_10.png"), preload("res://resources/cards/00_11.png"), preload("res://resources/cards/00_12.png"),
				preload("res://resources/cards/01_00.png"), preload("res://resources/cards/01_01.png"), preload("res://resources/cards/01_02.png"), preload("res://resources/cards/01_03.png"), preload("res://resources/cards/01_04.png"), preload("res://resources/cards/01_05.png"), preload("res://resources/cards/01_06.png"), preload("res://resources/cards/01_07.png"), preload("res://resources/cards/01_08.png"), preload("res://resources/cards/01_09.png"), preload("res://resources/cards/01_10.png"), preload("res://resources/cards/01_11.png"), preload("res://resources/cards/01_12.png"),
				preload("res://resources/cards/02_00.png"), preload("res://resources/cards/02_01.png"), preload("res://resources/cards/02_02.png"), preload("res://resources/cards/02_03.png"), preload("res://resources/cards/02_04.png"), preload("res://resources/cards/02_05.png"), preload("res://resources/cards/02_06.png"), preload("res://resources/cards/02_07.png"), preload("res://resources/cards/02_08.png"), preload("res://resources/cards/02_09.png"), preload("res://resources/cards/02_10.png"), preload("res://resources/cards/02_11.png"), preload("res://resources/cards/02_12.png"),
				preload("res://resources/cards/03_00.png"), preload("res://resources/cards/03_01.png"), preload("res://resources/cards/03_02.png"), preload("res://resources/cards/03_03.png"), preload("res://resources/cards/03_04.png"), preload("res://resources/cards/03_05.png"), preload("res://resources/cards/03_06.png"), preload("res://resources/cards/03_07.png"), preload("res://resources/cards/03_08.png"), preload("res://resources/cards/03_09.png"), preload("res://resources/cards/03_10.png"), preload("res://resources/cards/03_11.png"), preload("res://resources/cards/03_12.png")]
const back_texture = preload("res://resources/cards/Card_back_01.svg.png")

# Flag indicating if the texture was changed & needs updating
var update_texture_flag = false

# Returns the texture data that coorisponds with this card's suit & value.
func get_card_texture() -> Resource:
	var parent = get_parent()
	if !parent.flipped:
		var index = parent.get_suit_index() * 13 + parent.get_value_index()
		if index >= textures.size():
			print_debug("Was unable to get the correct texture index %s. suit = %s, value = %s" % [index, parent.card_suit, parent.card_value])
			return textures[0]
		return textures[index]
	else: # To get the back texture
		return back_texture

# Call this whenever the value of the card should change, will automatically
# update the object's texture on _ready() or on _process(delta).
func notify_texture_update():
	update_texture_flag = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.update_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update_texture_flag:
		self.update_texture()

# Retrieves the texture that matches this card's suit/value and set's this
# mesh's texture to the retrieved value
func update_texture():
	var text = get_card_texture() # Set the card's texture based off of it's initial value
	self.set_texture(text)
	update_texture_flag = false
