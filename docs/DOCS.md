# TOC & LEGEND

# Table of Contents

# Terms & Phrases

## "GettingStarted" or "the Starter Guide"

Refers to "GettingStarted.pdf"

Once it has been made, a PDF document guide for using this project as well as some general game design and production methodologies authored by myself. This DOCS.md is the work in progress for "GettingStarted.pdf" in addition to functioning as a temporary holding space for other non-script documentation.  Much of the information kept here for now may end up in the "Gettings Started.pdf" once it has been created, but the guide will focus more on using the project to create a game whereas this document is for the Starter Kit project on whole.

## Modules

module/component/extension

# Links

## Starter Kit

See [Installation]()

## Sample Game

The game seems stable besides a strange lag spike occuring a bit after the game starts if the player is active

- [Play Online](https://mymstake.itch.io/actionplatformerstarter)
	- Mobile users may experience a far amount of lag in general
	- iOS users might find the game unresponsive, use the latest platform build instead

### Demo Builds

- Download Sample Game - Likely to work better than HTML version
	- Beta 0.1.1
		- [Android]()
		- [iOS]()
		- [Linux]()
		- [Mac]()
		- [Windows]()

---

# Controls

No tutorial yet, so this might come in handy, mobile controls WIP

- **Move**: Gamepad Left Stick / W-A-S-D
- **Turn Camera**: Gamepad Right Stick / Mouse movement  
    - Hold right mouse to rotate the character (1st / 3rd person)
- **Jump**: Gamepad B (PlayStation Circle) / Spacebar
- **Crouch**: Gamepad Right Stick Button (R3) / Control (tap toggles, hold supported)
- **Sprint**: Gamepad Left Trigger / Shift
- **Zoom Camera**: Gamepad D-Pad Up/Down / Mouse Scroll / Keyboard Up/Down

## Debug Controls (Temporary)

- **Toggle Debug Menu / Teleporter**: Grave/Backtick (`\``) (no gamepad input yet, sorry)
- **Debug Cam**: Gamepad Left Shoulder (L1) / Tab  
    - Flies in facing direction; jump/crouch for vertical movement
    - **Change Speed**: (Gamepad input TBD)
- **Force Release Mouse Cursor**: Gamepad Menu / Escape
- **Quit Game**: Gamepad Back / Backspace

---

# Features

- An organized and documented player controller script (with an optional drag & drop player scene to swap assets, add custom nodes, and configure!)
- Universal 1st & 3rd person support
- Basic kinematics and foundational movement
- Implements 's Source-like FPS mechanics
- **Multi-Jump**: Double jump, triple jump, etc.
- **Air Control**: Source engine-inspired feel
- **Wall Surf**: Slopes 45°–89° are surfable
- **Crouch Jump**: Feet lift while crouching mid-air (instead of ducking)
- Debug menu with an easy teleporter — see `GettingStarted.md` (or the PDF)
- Fine-tunable adaptive FOV and zoom control
- Alternative mouse capture system for independent or synchronized look/turn via left/right click (similar to tab-target MMOs)

## Goals

### Future Features

- Mobile ports and controls
    - Just added to top of priority, beta 1.2 will feature the first mobile support.
- More movement candy:
    - Glide (battle royale or fantasy-style)
    - Dodge (configurable variations)
- Audio!
- Main Menu
- In-game Pause Menu
- More Debug Tools
- Multiplayer?
    - Proximity voice chat or bust
    - Emotes or bust
- Save files!?

### v1.0 (Launch Edition)

**In order of priority:**
- Stable Starter Project & Sample Game
	- No crashes
	- No medium severity or higher bugs
- Device Compatibility
	- Mobile friendly
		- iOS branch for Sample Game Demo
	- Forward+ ready
- Documented
	- Code syntax standardized
	- All original scripts fully "cleaned" for editor help documents (via F1)
- Modular
	- Each module of the project should:
		- be preset with values that present a minimal state
			- "Minimal state" being as near to 0, false, null, "", {}, or [] as possible without removing functionality
			- The Sample Game will have presets at the inteded values to make quick prototyping easier.
		- be independant enough to be removed (and/or replaced)
			- A documented removal / replacement process for each module should be listed in the Getting Started guide.
		- be customizable
			- A document report on each module should be clear and extensive
			- Functionality should make further extension and tweaks easy to integrate.
- Translated 
	- There's always 3rd party translators, but I don't want that to be a necessity for anyone
	- Top 10 language priorities no order:
		- Spanish, German, French, Chinese, Japanese, Portuguese, Italian, Korean, Russian, and Polish
	- All planned languages grouped by family (I'm no language expert so please do correct me):
		- English (British), German, Dutch, Polish, French, Italian, Spanish, Portuguese (Brazilian)
		- Russian, Greek, Hebrew, Turkish, Arabic (Egyptian & Levantine)
		- Japanese, Chinese (Simplified), Korean, Hindi, Thai, Vietnamese, Indonesian, Tagalog
		- _, _, _, etc., Nonstandard Language variations (ie. American/Canadian/Australian English, European Portuguese, Traditional Chinese)

---

# Installation

Clone the repo for the project files to get started!  Check the internal player script documentation for extra notes.  You can press F1 while the player script is open in the engine to view the class documentation in a more structured format.

This link should grab the [main.zip]().

<!-- Future Addon install instructions will go here -->

## Compatibility

- Godot Version: 4.4.x
- Physics Engine: Jolt
- Rendering: Compatibility Mode