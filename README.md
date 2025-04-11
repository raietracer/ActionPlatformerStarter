# Action Platformer Starter

## BETA DISCLAIMER

PLEASE DO NOT ATTEMPT TO MERGE THIS PROJECT WITH YOUR OWN  
*yet.* It's not ready.

Demo live on the asset page [Itch.io](https://mymstake.itch.io/actionplatformerstarter))!

This project is well underway, but it was also established very hastily and sloppily. There are many graphic assets currently included for testing purposes that will not remain for long, in order to keep licensing complications to a necessary minimum. I plan to replace all assets not created by hand in Godot or an art program with custom ones, and release them under the same MIT license as the code and project files.

The modularity of the project has been maintained through a plethora of exposed properties in the character controller's inspector. Once you have a local copy of the `action_platformer` directory, you should have everything necessary to link functionality into a different project — however, this hasn't yet been properly prepared or implemented and remains theoretical for now.

---

## Overview

A versatile, modular, feature-rich starting point for 3D platforming games built in Godot 4.4.

This project aims to help both new and experienced Godot users get started building a 3D action game. At the very least, it provides a stable movement script with a wide array of tuning options and easy potential for swapping out player graphics.

My goal is — upon completion — for the entire set of scenes, resources, and scripts to live in one neat folder, ready to drag and drop into your own project. Alternatively, it will also serve as a clean and functional starter project for those building from scratch.

---

## Features

- An organized and documented player controller script (with an optional drag & drop player scene to swap assets, add custom nodes, and configure!)
- Universal 1st & 3rd person support
- Basic kinematics and foundational movement
- Implements [Majikayo Games](https://www.youtube.com/@MajikayoGames)'s Source-like FPS mechanics
- Includes stair handling and pushable object collision with mass weighting from the same series
- **Multi-Jump**: Double jump, triple jump, etc.
- **Air Control**: Source engine-inspired feel
- **Wall Surf**: Slopes 45°–89° are surfable
- **Crouch Jump**: Feet lift while crouching mid-air (instead of ducking)
- Debug menu with an easy teleporter — see `GettingStarted.md` (or the PDF)
- Fine-tunable adaptive FOV and zoom control
- Alternative mouse capture system for independent or synchronized look/turn via left/right click (similar to tab-target MMOs)

---

## Controls

No tutorial yet, so this might come in handy:

- **Move**: Gamepad Left Stick / W-A-S-D
- **Turn Camera**: Gamepad Right Stick / Mouse movement  
    - Hold right mouse to rotate the character (1st / 3rd person)
- **Jump**: Gamepad B (PlayStation Circle) / Spacebar
- **Crouch**: Gamepad Right Stick Button (R3) / Control (tap toggles, hold supported)
- **Sprint**: Gamepad Left Trigger / Shift
- **Zoom Camera**: Gamepad D-Pad Up/Down / Mouse Scroll / Keyboard Up/Down

### Debug Controls (Temporary)

- **Toggle Debug Menu / Teleporter**: Grave/Backtick (`\``) (no gamepad input yet, sorry)
- **Debug Cam**: Gamepad Left Shoulder (L1) / Tab  
    - Flies in facing direction; jump/crouch for vertical movement
    - **Change Speed**: (Gamepad input TBD)
- **Force Release Mouse Cursor**: Gamepad Menu / Escape
- **Quit Game**: Gamepad Back / Backspace

---

## Future Features

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

## Installation

Currently, the only guaranteed way to implement the player controller correctly is to start with this project directly.

<!-- Future Addon install instructions will go here -->

### Downloads

- [Download Starter Project](https://github.com/raietracer/ActionPlatformerStarter/archive/refs/heads/main.zip) (same as downloading .zip of repo)

---

## Compatibility

- Godot Version: 4.4.1
- Physics Engine: Jolt
- Rendering: Compatibility Mode

---

## Version

### 0.1.0 Beta Stable

**First push**, initial repository — *Uploaded 11 April 2025*

#### Known Issues

- Stair handling currently uses two methods that alternate at runtime depending on framerate when standing at step midpoints  
    - Plan: Default to upward and force downward handling during descent states
- The project **cannot yet** be imported by simply dragging and dropping the `action_platformer` folder into another Godot 4.4 project

---

## Licensing

This project is licensed under the MIT License for its original code.

However, included assets (sprites, sounds, etc.) may be licensed separately.  
Some assets may be free for non-commercial use only. Please see `gfx/LICENSES.md` for details.
