package plac3d.gfx;

import motion.Actuate;
import openfl.display.Shape;
import openfl.display.Sprite;


class VirtualJoystick extends Sprite {
    var background:Shape;
    var knob:Shape;
    public var diameter(default, null):Float;
    var currentX:Float = 0.0;
    var currentY:Float = 0.0;

    public function new(diameter:Float) {
        super();
        this.diameter = diameter;

        var centerX = diameter / 2;
        var centerY = centerX;

        background = new Shape();
        background.graphics.beginFill(0xB0C4DE);
        background.graphics.drawCircle(centerX, centerY, diameter / 2);
        background.graphics.endFill();
        background.alpha = 0.2;

        var knobWidth = diameter * 0.4;
        knob = new Shape();
        knob.graphics.beginFill(0x4682B4);
        knob.graphics.drawCircle(centerX, centerY, knobWidth / 2);
        knob.graphics.endFill();
        knob.alpha = 0.6;

        addChild(background);
        addChild(knob);
    }

    public function setPosition(x:Float, y:Float) {
        var radius = diameter / 2;
        knob.x = radius * x;
        knob.y = radius * y;

        var dirty = x != currentX || y != currentY;

        if (dirty && x == 0 && y == 0) {
            Actuate.tween(background, 0.5, {alpha: 0.2});
            Actuate.tween(knob, 0.5, {alpha: 0.6});
        } else if (dirty && currentX == 0 && currentY == 0) {
            Actuate.tween(background, 0.5, {alpha: 0.6});
            Actuate.tween(knob, 0.5, {alpha: 1.0});
        }

        currentX = x;
        currentY = y;
    }
}
