package plac3d.gfx;

import openfl.display.Shape;
import openfl.display.Sprite;


class PlayerHeight extends Sprite {
    var heightShape:Shape;
    var backgroundShape:Shape;

    public function new() {
        super();

        heightShape = new Shape();
        heightShape.graphics.beginFill(0xA0522D);
        heightShape.graphics.drawRect(0, 0, 4 , 16);
        heightShape.graphics.endFill();

        backgroundShape = new Shape();
        backgroundShape.graphics.beginFill(0x87CEEB);
        backgroundShape.graphics.drawRect(0, 0, 4, 16);
        backgroundShape.graphics.endFill();

        addChild(heightShape);
        addChild(backgroundShape);
    }

    public function setPlayerHeight(height:Float) {
        height = Math.min(1, height);
        backgroundShape.height = 16 * (1 - height);
    }
}
