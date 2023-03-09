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
                "suit_back_override": "", // Can include texture override for an entire suit's back face
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
                "suit_id": -1, // If symmetrical_deck is false, you would need to declare the suit_id of the cards, here you can either omit it, like the other card objects in this example or have it be -1 (invalid value)
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

The example deck didn't have any repeating card_ids in the content field, but they can be repeated any number of times.

### Rulesets

At their core, rulesets define the game's possible states and what can occur when the game is in those states, depending on the game, not all players would be in the same game state. In a game that is played consecutively in rounds, players would all generally be within the same game state, and a particular action or set of actions can change the state for all the players and advance the game. In other games where the game flow is more organic and freeform, the game could be playing concurrently (at the same time) in different ways for different people on the same game server.

The basic building blocks for a `ruleset` are, `state`, `action`, `card set`, and `deck`. Potential concept of a `global_state` if a user wants to store a persistent value that is not connected to a particular player (May not be implemented, depending on how the API ends up).

A `state` would define data, what actions are available under defined conditions, what players the state encompasses, and how the state organizes play.

An `action` could define any combination of `primitive_actions` to occur in a sequence, and can conditionally control the game's data and state.

A `primitive_action` would be how to directly interact with the game world, it is the API that content creators will have access to to create their own custom game content. Data, or arguments can also be passed to the primitives when they are declared in an action, this would allow fine grained control of what occurs. An example of a primitive action would be `draw_card`, where arguments can be passed to define to where the card goes (Player hand, or a defined location), and if it is revealed (facedown) or not.

A ruleset file can either refer to outside resources (Such as `decks` and `card sets` json files), or it can declare them in the same file, making it a larger, or "fat" file. Here's an example of a "fat" `ruleset` file that could potentially define a game similar to [Skull](https://boardgamegeek.com/boardgame/92415/skull), `skullable.json`:

```jsonc
{
    // Please be aware the API is still very much a work in progress and there may still be some issues or missing features
    "cardset": {
        "set_name": "Skull & Flowers",
        "card_dimensions": {
            "width": 150,
            "height": 150,
        },
        "suits": [ // Honestly not sure about all the suit names, if trying to match the actual game. We have 6 suits.
            {
                "suit_name": "Vikings",
                "suit_id": 0,
                "suit_colour": {
                    "red": 0,
                    "green": 255,
                    "blue": 0,
                },
                "suit_back_override": "viking_back.png",
            },
            {
                "suit_name": "Samurai",
                "suit_id": 1,
                "suit_colour": {
                    "red": 255,
                    "green": 0,
                    "blue": 0,
                },
                "suit_back_override": "samurai_back.png",
            },
            {
                "suit_name": "Shamen",
                "suit_id": 2,
                "suit_colour": {
                    "red": 241,
                    "green": 202,
                    "blue": 121,
                },
                "suit_back_override": "shamen_back.png",
            },
            {
                "suit_name": "Voodoo",
                "suit_id": 3,
                "suit_colour": {
                    "red": 106,
                    "green": 32,
                    "blue": 89,
                },
                "suit_back_override": "voodoo_back.png",
            },
            {
                "suit_name": "Zulu",
                "suit_id": 4,
                "suit_colour": {
                    "red": 0,
                    "green": 0,
                    "blue": 255,
                },
                "suit_back_override": "zulu_back.png",
            },
            {
                "suit_name": "Animist",
                "suit_id": 5,
                "suit_colour": {
                    "red": 102,
                    "green": 100,
                    "blue": 194,
                },
                "suit_back_override": "animist_back.png",
            },
        ],
        "symmetrical_deck": true,
        "cards": [ // Just need 2 types of cards
            {
                "card_name": "Skull",
                "card_id": 0,
                "card_value": 1,
            },
            {
                "card_name": "Flower",
                "card_id": 1,
                "card_value": 0,
            },
        ],
    },
    "deck": [ // We are declaring multiple decks, so we use an array of objects [], instead of an object {}
        {
            "deck_name": "Vikings",
            "cardset": "Skull & Flowers",
            "content": [
                0, 1, 1, 1
            ],
        },
        {
            "deck_name": "Samurai",
            "cardset": "Skull & Flowers",
            "content": [
                2, 3, 3, 3
            ],
        },
        {
            "deck_name": "Shamen",
            "cardset": "Skull & Flowers",
            "content": [
                4, 5, 5, 5
            ],
        },
        {
            "deck_name": "Voodoo",
            "cardset": "Skull & Flowers",
            "content": [
                6, 7, 7, 7
            ],
        },
        {
            "deck_name": "Zulu",
            "cardset": "Skull & Flowers",
            "content": [
                8, 9, 9, 9
            ],
        },
        {
            "deck_name": "Animist",
            "cardset": "Skull & Flowers",
            "content": [
                10, 11, 11, 11
            ],
        },
    ],
    "ruleset": {
        "ruleset_name": "Skullable",
        "description": "Game of bluffs & strategy!",
        "min_players": 3,
        "max_players": 6,
        "cardsets": [
            "Skull & Flowers",
        ],
        "decks": [
            "Vikings", "Samurai", "Shamen", "Voodoo", "Zulu", "Animist",
        ],
        "game_area": {
            // Define player positions, deck positions (if any), card placement positions in play area, etc.
            // ...
        },
        "global_data": [ // We can store some global data here, could be const or not
            {
                "key": "start_player",
                "value": "",
                "type": "player", // This can be omitted, or provided with 'any'
            },
        ],
        "game_state": [
            {
                "state_name": "deck_selection",
                "state_type": "auto",
                "state_params": [
                    {
                        "param": "", // parameter name/identifier
                        "type": "", // type of parameter
                    },
                ],
                "state_data": [
                    {
                        "key": "", // data name/identifier, if same as a param, will receive value from whatever argument value is passed in the parameter's place
                    },
                ],
                "actions": [ // This state will not be how this kind of thing would be achieved in the final API, still thinking about alternatives
                    {
                        "action_name": "pick_deck",
                        "action_type": "auto", // Auto actions cannot be picked by a player and act out automatically (In order) when in the state and can be conditionally controlled
                        "primitives": {
                            "endpoint": "pick_deck", // Will not be in final API
                            "params": [
                                "game.decks", "globals.start_player", // The player to start first in a round will be abstracted out in the final API
                            ],
                        },
                    },
                    {
                        "action_name": "transition",
                        "type": "auto",
                        "primitives": {
                            "endpoint": "state_transition",
                            "params": "pregame",
                        },
                    },
                ],
            },
            {
                "state_name": "pregame",
                "state_type": "auto",
                "actions": [
                    {
                        "action_name": "choose_player",
                        "type": "auto",
                        "condition": {
                            "endpoint": "is_empty",
                            "params": "globals.start_player",
                        },
                        "primitives": {
                            "endpoint": "pick_random_player",
                            "params": "globals.start_player",
                        },
                    },
                    {
                        "action_name": "give_cards",
                        "type": "auto", 
                        "primitives": [
                            {
                                "endpoint": "empty_hands", // Makes sure everyone has no cards
                                "params": "all",
                            },
                            {
                                "endpoint": "draw_cards",
                                "params": [
                                    "all", 4, "player.deck", "player.hand", // Draw cards, for all players, 4 each, from each player's personal deck, to the player's hand.
                                ],
                            },
                        ],
                    },
                    {
                        "action_name": "transition",
                        "type": "auto",
                        "primitives": {
                            "endpoint": "state_transition",
                            "params": "round_start",
                        },
                    },
                ]
            },
            {
                "state_name": "round_start",
                "state_type": "concurrent", // All players get notified and asked to perform the action at the same time
                "actions": [
                    {
                        "action_name": "Place card facedown",
                        "action_message": {
                            "type": "center_screen",
                            "size": 60,
                            "text": "You must choose a card from your hand to play facedown!",
                            "time": -1, // The message will be on screen the entire time until this action is taken (since there is no 'condition' field)
                        },
                        "type": "hand_pick",
                        "type_params": 1, // Optional, but says to 'hand_pick' to only accept 1 card
                        "primitives": {
                            "endpoint": "place_card",
                            "params": [
                                "action.hand_pick", "player.front", true // Place card, the card the player picked, placed at the location called "front" belonging to the player, while facedown
                            ],
                        },
                    },
                    {
                        "action_name": "transition",
                        "type": "auto",
                        "condition": {
                            "endpoint": "is_equal", // Are the two arguments passed equal?
                            "params": [ "active_players", 0 ], // active_players returns how many people can still select an action
                        },
                        "primitives": {
                            "endpoint": "state_transition",
                            "params": "round_phase_one",
                        }
                    }
                ]
            },
            {
                "state_name": "round_phase_one",
                "state_type": "round_robin",
                "state_type_param": "globals.start_player",
                "actions": [
                    {
                        "action_name": "Place card facedown",
                        "type": "hand_pick", // The action is performed by clicking a card in your hand and confirming your choice
                        "type_params": 1, // Optional, but says to 'hand_pick' to only accept 1 card
                        "primitives": {
                            "endpoint": "place_card",
                            "params": [
                                "action.hand_pick", "player.front", true // Place card, the card the player picked, placed at the location called "front" belonging to the player, while facedown
                            ],
                        },
                    },
                    {
                        "action_name": "Bet # of flowers flipped in a row", // How can I make this more concise?
                        "type": "button",
                        "action_data": {
                            "key": "player_bet",
                            "type": "number",
                        },
                        "primitives": [
                            {
                                "endpoint": "prompt_number",
                                "params": [
                                    "action.player_bet"
                                ],
                            },
                            {
                                // wip
                            }
                        ],
                    },
                    {
                        "action_name": "transition",
                        "type": "auto",
                        "condition": {
                            "endpoint": "is_equal", // Are the two arguments passed equal?
                            "params": [ "active_players", 0 ], // active_players returns how many people can still select an action
                        },
                        "primitives": {
                            "endpoint": "state_transition",
                            "params": "round_phase_one",
                        }
                    }
                ]
            },
            {
                // ... Still needs more states to be a complete game, WIP.
            }
        ]
    },
}
```

The API format will permit `actions` to be defined outside of the `state` definition, allowing for more succinct state action info.
