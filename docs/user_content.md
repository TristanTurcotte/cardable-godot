# Cardable user content

How will user content be managed? How will it be created? How will it interact with the multiplayer component? Will connecting players have to download config & resources before they join a game?

What can a user add or modify in the game? What are the limits, what are the concrete capabilities, and how is it achieved?

## Requirements

How user content is created and managed is the cornerstone of this project, as `rulesets` to dictate how the game is run and what happens in the game is the main form of user content and also how the game acts as an actual game, besides skins and re-textures of the regular playing cards.

- Two types of user content: `ruleset` and `card set`
  - Rulesets would define the game and what actions can be taken.
  - Card sets would define what cards are available in the game. A ruleset would declare which card set or sets it makes use of. They would provide a list of all the types of cards available and any metadata (Like texture, value, card suit (if applicable), etc.).

### Card sets

- Declares which cards are available.
- Declares the values and attributes of the cards, such as texture, size, value, name, suit, back texture, etc.
- A card set would be contained in a folder, named after the set, with a config.json file in the root, and a particular file hierarchy for the card textures.
  - In the root of the card set folder, you would have a folder called `resources` and a file called `cardset.json`. You can optionally include a `decks` folder.
  - In the `resources` folder, you would have a folder for each of your set's suits, named after the suits, or with an override folder name. In each suit's folder, you would include an image file for each card with the filenames starting from for example, 0.png, or ace.png (Depending on if `use_id_for_texture_names` is true or false).
  - In the `decks` folder, arbitrarily named `.json` files can be found. Each individual file would contain a deck that is provided by the card set (The decks don't _have_ to use the card set in the root folder and could rely on another `card set`).

Here's an example `.json` file showing a potential format for creating custom `card sets`:

```jsonc
{
    "cardset": {
        "set_name": "Standard Playing Cards",
        "card_dimensions": {
            "width": 90,
            "height": 135,
        },
        "card_back": "Card_back_01.svg.png", // Name of the back texture
        "suits": [
            {
                "suit_name": "Hearts",
                "suit_id": 0, // from 0, 1, 2, 3 for a standard deck
                "suit_colour": {
                    "red": 255,
                    "green": 0,
                    "blue": 0,
                },
                "suit_back_override": "", // Can include texture override for an entire suit's back
                "texture_folder_override": "hearts", // Folder name in `resources` folder that contain's this set's textures
            },
            {
                // ...
            },
        ],
        "symmetrical_deck": true, // If true, you only need to define the unique cards in 1 suit, and they'll be replicated to the other suits
        "use_id_for_texture_names": false, // Can be omitted, default is false. If provided, will search for 0.png, 1.png instead of ace.png, two.png.
        "cards": [
            {
                "card_name": "Ace",
                "card_id": 0,
                "card_value": 1,
                "texture_override": "", // Name of the texture file, if none is provided, it is assumed the texture file's name is the card_name, all lowercase. e.g. ace.png
                "card_back_override": "", // Can include a texture override for the back texture, if symmetrical mode is on and an override is provided, every suit of the same value card would have the same back texture (Probably not desired)
            },
            {
                "card_name": "Two",
                "card_id": 1,
                "card_value": 2,
                "texture_override": "", // card_back_override can be omitted
            },
            {
                // ...
            },
            {
                "card_name": "Joker",
                "card_id": 13,
                "card_value": -1, // texture_override can be omitted as well
            },
        ],
    },
}
```

A card set would define all the individual unique card types that are available, and then there would also be a `.json` config file for a particular deck/collection of cards to be actually used in-game. A `ruleset` would declare which `card set(s)` it uses and then also declares what `decks` to use, if no deck is declared a deck made from 1 of every card from the `card set` would be the ruleset's deck.

As described above Decks can be provided in a package with a card set, they can also be used separate from a card set package and distributed by themselves. The game would have a `user-decks` folder or similar where 'loose' deck `.json` files are placed.

The content of the deck config file is simply an array of card_ids and the name of the card set the deck uses. Here's an example `.json` of a deck config file, in this case `deck-std-no-joker.json`:

```jsonc
{
    "deck": {
        "deck_name": "Standard, No Jokers",
        "cardset": "Standard Playing Cards",
        "content": [ // Note that 13, 27, 41, & 55 are missing (The Jokers!)
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54
        ],
    },
}
```

### Rulesets

- Declares what actions can be performed.
- Declares when actions can be performed.
- ...

```jsonc
{

}
```
