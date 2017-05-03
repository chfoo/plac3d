package plac3d.gfx;

#if html5
import js.Browser;
#end
import openfl.system.Capabilities;


class Screen {
    public function new() {
    }

    static public function getPixelScale():Float {
        #if html5
        if (Browser.window.devicePixelRatio != null) {
            return Browser.window.devicePixelRatio;
        }
        #end

        if (Capabilities.screenDPI != 0) {
            return Capabilities.screenDPI / 72;
        } else {
            return 1.0;
        }
    }
}
