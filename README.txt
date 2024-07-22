02/06/2024 Modular2D Platformer Character Controller by Sarah Watts

Package Features:
Features of this package.
- player_character.tscn, Modular 2D Character controller.
- Tileset.tres with physics layer set up with a Tilemap node ready for prototyping.
- custom_camera.tscn for the player(smooths the ledge climb position move)

Package Limitations:
- Considering using the custom_camera node or create one yourself if you plan to use ledge
  climb to smooth the snapping of position
- Ledge climb will be enabled if wall climb state is enabled.
- Single player controller – no multiplayer controller support
- No Input Map support - you can rebind input keys through the player character.
- Certian tilemap level building limitations (Refer to LevelBuildingLimitations.png for details).

Implementation of 2DPlatformCharacterController:
-Place the SWPlatformerPackage folder into your godot project's root directory.

Using the camera:
-Attach the CustomCamera Node as a child of PlayerCharacter for it to follow the player around.

Changing default Godot Project settings for a pixel art game.
-Consider changing the settings listed below to remove the blurring of pixels.

General/Rendering/Textures/CanvasTextures/Default Texture Filter from (Linear) to (Nearest Mipmap).

Default keys:
Z Jump
X Hold to Climb wall
A Glide
D Hold to Crouch
C Dash