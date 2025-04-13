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

## Future Features

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

---

# Installation

Clone the repo for the project files to get started!  Check the internal player script documentation for extra notes.  You can press F1 while the player script is open in the engine to view the class documentation in a more structured format.

This link should grab the [main.zip]().

<!-- Future Addon install instructions will go here -->

## Compatibility

- Godot Version: 4.4.x
- Physics Engine: Jolt
- Rendering: Compatibility Mode