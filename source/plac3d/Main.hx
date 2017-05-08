/*
Plac3d
Copyright 2017 Christopher Foo
License: GPLv3
 */

package plac3d;


import lime.system.System;
import openfl.Lib;
import openfl.display.Sprite;
import Random;
#if html5
import js.Browser;
#end


class Main extends Sprite {
    public function new() {
        super();

        // Lime/OpenFL forces screen to stay on, but we'll restore the expected
        // behavior of traditional apps
        System.allowScreenTimeout = true;

        var scene = new Scene(this);

        scene.setPosition(
            Random.int(0, Scene.PIXEL_CANVAS_WIDTH - 1),
            Random.int(0, Scene.PIXEL_CANVAS_HEIGHT -1)
        );

        #if html5
        var pattern = new EReg(".*([xy])=([0-9]+).*([xy])=([0-9]+)", "");
        var result = pattern.match(Browser.location.hash);

        if (result) {
            var x = null;
            var y = null;
            if (pattern.matched(1) == "x") {
                x = Std.parseInt(pattern.matched(2));
            } else {
                y = Std.parseInt(pattern.matched(2));
            }

            if (pattern.matched(3) == "x") {
                x = Std.parseInt(pattern.matched(4));
            } else {
                y = Std.parseInt(pattern.matched(4));
            }

            if (x != null && y != null) {
                scene.setPosition(x, y);
            }
        }

        var aboutContainer = Browser.document.createDivElement();
        Browser.document.body.appendChild(aboutContainer);
        var version = Lib.application.config.version;

        aboutContainer.innerHTML = '
            <div style=\"position:fixed;bottom:0px;right:0px;text-align:center;background:rgba(255,255,255,0.5);border-radius:0.1em;\">
                Version $version.
                Built with Away3D + OpenFL + Haxe. <a href=\"https://github.com/chfoo/plac3d\">More info.</a>
            </div>
        ';
        #end
    }
}
