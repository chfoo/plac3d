package plac3d.gfx;

import openfl.display.Bitmap;
import openfl.utils.Assets;
import openfl.display.Sprite;


class HelpOverlay extends Sprite {
    public function new() {
        super();

        graphics.beginFill(0x000000, 0.5);
        graphics.drawRoundRect(0, 0, 200, 200, 10, 10);
        graphics.endFill();

        var bitmapData = Assets.getBitmapData("assets/controls.png");
        var bitmap = new Bitmap(bitmapData);
        bitmap.width = 200;
        bitmap.height = 200;

        addChild(bitmap);
    }
}
