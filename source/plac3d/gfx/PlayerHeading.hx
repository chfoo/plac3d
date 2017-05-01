package plac3d.gfx;

import openfl.display.GraphicsPathCommand;
import openfl.Vector;
import openfl.display.Shape;


class PlayerHeading extends Shape {

    public function new() {
        super();
        graphics.beginFill(0xFFD700, 0.8);
        graphics.lineStyle(1, 0x000000);

        var commands = Vector.ofArray([
            GraphicsPathCommand.MOVE_TO,
            GraphicsPathCommand.LINE_TO,
            GraphicsPathCommand.LINE_TO,
            GraphicsPathCommand.LINE_TO
        ]);
        var values = Vector.ofArray([
            0.0, -8,
            4, 8,
            -4, 8,
            0, -8
        ]);

        graphics.drawPath(commands, values);
        graphics.endFill();
    }
}
