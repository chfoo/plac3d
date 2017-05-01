package plac3d.gfx;

import openfl.display.Shape;


class Compass extends Shape {
    public function new() {
        super();
        graphics.beginFill(0xFF0000);
        graphics.drawRoundRect(-2, -8, 4, 8, 2);
        graphics.endFill();
        graphics.beginFill(0xffffff);
        graphics.drawRoundRect(-2, 0, 4, 8, 2);
        graphics.endFill();
    }
}
