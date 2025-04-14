## Quick Start

Ready to get started on a new 3D Platformer project?  Try this starter kit filled with various hand-picked modules to get you building and playtesting levels ASAP!

**First**, download the [_latest stable project release_]() (this link to the releases should start the download.)
Once you've extracted to your location of choice, navigate to the docs folder to find DOCS.md then open the project file in Godot 4.4.x and follow along!
A copy of the sample game with the Getting Started guide is the intended method of picking up this project, but the Getting Started guide hasn't gotten started yet *drum taps*

## Project Description

This project aims to help both new and experienced Godot users get started building a 3D action game. At the very least, it provides a stable movement script with a wide array of tuning options and easy potential for swapping out player graphics and playtesting levels quickly.

My goal upon completion is for the entire set of scenes, resources, and scripts to live in one neat folder, ready to drag and drop into your own project. Alternatively, it will also serve as a clean and functional starter project for those building from scratch.

Major credit to [Majikayo Games](https://www.youtube.com/@MajikayoGames) who's tutorial series was invaluable for getting the source engine air control feel.  There are more mechanics from the same tutorial series being implemented such as the system for prop physics, stair and ladder handling, as well as the core for player picked interaction via SpringArm3D nodes using sphere shapes to check camera focus.

To get started with the starter kit, download the main branch .zip [here]()

---

# Overview

A versatile, modular, feature-rich starting point for 3D platforming games built in Godot 4.4.

---

# Patch Notes

## v0.1.1.8 (Alpha web patch 8)
> ***Uploaded 14 April 2025***
> **Highlights**
- Debug level migrated to new working overworld
- Audio Manager integrated with new Music Player (found in the Debug Menu)
- Coins working, Mirrors almost mirrors, dust gathering
- HTML5 web game export (itch demo) is being a pain in the rump
	- Audio not working what-so-ever
	- Graphics less than sub-par to desktop exports
	- Mobile practically unplayable even with gamepad controls due to lag and further loss in visuals
	- Resisting the urge to remove web build compatibility from the project, it could cause massive delays if I don't

> See VERSIONS.md for in-depth version details

---

# Compatibility

- Godot Version: 4.4.1
- Physics Engine: Jolt
- Rendering: Compatibility Mode

---

## BETA DISCLAIMER

Demo live on the asset page [Itch.io](https://mymstake.itch.io/actionplatformerstarter))!

The modularity of the project has been maintained through a plethora of exposed properties in the character controller's inspector. Once you have a local copy of the `action_platformer` directory, you should have everything necessary to link functionality into a different project — however, this hasn't yet been properly prepared or implemented and remains theoretical for now.