# Version Notes

## 0.1.1 Beta web patch

- Fixed the sloped surface jump issue and debug menu.
- Pinned down and managed jump height extending to re-enable it.
	- Holding jump dampens the effects of gravity until jump is released
		- only from the start of jumps

## 0.1.1 Beta Stable

Still some bugs
- Can't jump while ascending any sloped surface
- Debug Menu dropdown keeping focus while menu showing
- Momentum disappears if the player air jumps with direction unaligned to current velocity

## 0.1.0 Beta Stable

**First push**, initial repository — *Uploaded 11 April 2025*

### Known Issues

- Stair handling currently uses two methods that alternate at runtime depending on framerate when standing at step midpoints  
    - Plan: Default to upward and force downward handling during descent states
- The project **cannot yet** be imported by simply dragging and dropping the `action_platformer` folder into another Godot 4.4 project