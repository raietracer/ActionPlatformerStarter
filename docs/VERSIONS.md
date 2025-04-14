# Release (v1.0 +)

# Pre-releases (v0.x)

## v0.1.x (Open Beta)

---

### v0.1.2 (Alpha 2)
> ***In development***
> 
> **Goals**
- Mobile functionality is highest priority
	- On screen controls
		- GUI
		- Script integration

---

## v0.1.1.8 (Alpha web patch 8)
> ***Uploaded 14 April 2025***
> 
> **Highlights**
- Mobile controls put on pause while restructuring and searching for air-control bugfix
	- Air Control seems unchangable without losing all source engine carry-overs, looking into it.
- Debug level migrated to new working overworld
- The web build in general is being very difficult.
	- Focusing more on 'game code' has distracted from the massive graphics drop in the HTML5 export on itch.
	- Publishing most recent update to itch regardless for the sake of passers by.
- CSGMirrorBox3D, Pickups, and BobbingNode added for easy duplication of specific and/or common use-cases.
- Coins can now be collected via collision and click.  Pickup collision box distinct from physics collision box on both ends.
- Sample player data and progression system working, file save on the way
> **Bugs**
- Player still having Air Control issues
	- Still trying to pin down how to increase air acceleration to fix jump feel which is currently sticky and miserable
- Stairs are still a mess
	- making sure they're solid helps (see the steps in the demo)
	- speed matters a lot for thin steps (in regards to the tripping bug)
- Coin bobbing does some math: not the math I intended it to do but it sure is valid math.
	- Default values adjusted for the time being, real math coming soon

---

### v0.1.1.7 (Alpha web patch 7)
> ***Uploaded 14 April 2025***
> 
> **Highlights**
- Audio Manager integrated with new Music Player (found in the Debug Menu)
- Coins working, Mirrors almost mirrors, dust gathering
> **Bugs**
- I take it back, bugs are the greatest of my concerns.
- HTML5 web game export (itch demo) is being a pain in the rump
	- Audio not working what-so-ever
	- Graphics less than sub-par to desktop exports
	- Mobile practically unplayable even with gamepad controls due to lag and further loss in visuals
	- Resisting the urge to remove web build compatibility from the project, it could cause massive delays if I don't

---

### v0.1.1.3 ~ v0.1.1.6 (Web Patches 3 - 6)
> ***Uploaded 13 April 2025***
> 
> **Highlights**
- Preparing the HUD
	- It seems like the most practical step for a properly modular on-screen control scheme for mobile
	- Added debug trackers
		- Music Player
			- Non-functional as well as all audio on HTML5
				- looking into it
		- AFK Timer
			- Essentially a framerate locked tracker that resets if velocity is non-zero.  Notably -intentionally- counts physics frames, not timespans.
			- Used for dust[^dust]
		- Velocity tracker
			- Using this as a lightweight linked GUI example to point out in the Getting Started guide for the Starter Project when the time comes
			- For now it's a bit ugly, redesign on later polish along with all pack assets (editor properties, models, sprites, audio, textures, etc.)
	- Added currency trackers
		- One each for coins and 'dust' ('dust' being another guide example this time for an lightweight integrated player data stat with accompanying GUI link)
	- Moved debug fps / vsync display out of the Debug Menu to a temporary location with the volume button while they both wait on a real settings menu.
> **Bugs**
- I'm doing the opposite of dusting, bugs are the least of my concerns.
[^dust]: Dust tracks player afk frames in their local framerate, this means that laggy machines will accrue dust slower, intentionally designed as a mockery against fair balance.  Landing hard enough to take fall damage (*not yet implemented*)


---

### v0.1.1.1 + v0.1.1.2(Web Patch 1 & 2)
> ***Uploaded 12, 13 April 2025***
> 
> **Highlights**
- Fixed the sloped surface jump issue and debug menu.
- Pinned down and managed jump height extending to re-enable it.
	- Holding jump dampens the effects of gravity until jump is released
		- only from the start of jumps
> **Bugs**
- Control of Air Control seemed to have been lost.  MAJOR TOM?!
---

### 0.1.1.0 (Alpha 1)
> ***Uploaded 12 April 2025***
> 
> **Highlights**
- The beginnings of GUI
> **Bugs**
- Can't jump while ascending any sloped surface
- Debug Menu dropdown keeping focus while menu showing
- Momentum disappears if the player air jumps with direction unaligned to current velocity

---

### 0.1.0 (Open Beta Launch)
> *First push*, initial repository — ***Uploaded 11 April 2025***
> 
> **Highlights**
- I was so concerned with bugs at the time I didn't consider writing the features down as patch notes had any point.
- Most of the base functionality not listed in a patch note from here on out was added at once with the initial state of the repository.
> **Bugs**
- Stair handling currently uses two methods that alternate at runtime depending on framerate when standing at step midpoints  
	- Plan: Default to upward and force downward handling during descent states
- The project **cannot yet** be imported by simply dragging and dropping the `action_platformer` folder into another Godot 4.4 project
