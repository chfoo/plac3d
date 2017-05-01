package plac3d;

import openfl.utils.Assets;
import openfl.utils.ByteArray;

class Placements {
    public static var WIDTH = 1000;
    var data:ByteArray;

    public function new() {
        data = Assets.getBytes("assets/placements.data");
    }

    public function getFrequency(x:Int, y:Int):Int {
        var index = (x + WIDTH * y) * 2;
        return (data[index] << 4) | (data[index + 1] >> 4);
    }

    public function getColorIndex(x:Int, y:Int):Int {
        var index = (x + WIDTH * y) * 2;
        return data[index + 1] & 0x0f;
    }

    public function getColor(x:Int, y:Int):Int {
        var index = (x + WIDTH * y) * 2;
        return ColorTable.COLOR[data[index + 1] & 0x0f];
    }
}
