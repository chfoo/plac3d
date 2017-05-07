Plac3d
======

First-person 3D visualizer of r/place.

Plac3d puts you onto the final canvas of r/place, Reddit's 2017 April
Fools' event, as a 3D visualization where you can look and walk around.

With each pixel represented as a column of varying heights, you can explore
the placement activity of the canvas. The taller the column, the more times
a pixel has been placed there. It is logarithmically scaled for visual
effect.


Play
====

View Plac3d in your web browser at https://chfoo.github.io/plac3d/. You
will need a fast computer or mobile device with a fast GPU to avoid slow
performance.

Also available on [Android on Google Play](https://play.google.com/store/apps/details?id=io.github.chfoo.plac3d).
Other platforms not yet available.

To look around, click to activate pointer lock or drag the scene. To walk,
use the keyboard with the arrow or WASD keys. Touchscreen users can use 
the on-screen virtual joystick to walk. Click on the minimap to show FPS
stats.


Build
=====

To build Plac3d, you will need an environment for Haxe.

Requirements:

* Haxe 3.4.2
* OpenFL 4.9.2
* Away3D 5.0.2
* Actuate 1.8.7
* Random 1.4.1

1. Get Haxe from [here](http://haxe.org/download/). If not using the
installer, unzip into a directory. Ensure the binary are in path and run 
`haxelib setup`.
2. Install OpenFL

        haxelib install openfl
        haxelib run openfl setup

3. For HTML5, there is no other setup needed. For other platforms, see
[these instructions](http://www.openfl.org/lime/docs/advanced-setup/).
4. Install the other libraries:

        haxelib install away3d
        haxelib install actuate
        haxelib install random
5. Build the project:

        openfl test html5 -minify


Issues
======

Bug reports or problems? Please file an issue on the GitHub issue 
tracker.
