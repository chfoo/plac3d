package plac3d.gfx;

import openfl.display.Shape;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;


class Minimap extends Sprite {
    var placements:Placements;
    var bitmap:Bitmap;
    var playerHeading:PlayerHeading;
    var compass:Compass;
    var label:TextField;
    var currentX:Int;
    var currentY:Int;
    var minimapSize:Int;
    var playerHeight:PlayerHeight;

    public function new(placements: Placements, minimapSize:Int = 80) {
        super();

        this.placements = placements;
        this.minimapSize = minimapSize;

        var scale = minimapSize / 80;

        var data = new BitmapData(40, 40);
        bitmap = new Bitmap(data);
        bitmap.alpha = 0.8;
        bitmap.scaleX = bitmap.scaleY = 2 * scale;

        playerHeading = new PlayerHeading();
        playerHeading.x = bitmap.width / 2;
        playerHeading.y = bitmap.height / 2;
        playerHeading.scaleX = playerHeading.scaleY = scale;

        compass = new Compass();
        compass.x = 8 * scale;
        compass.y = 8 * scale + bitmap.height;
        compass.scaleX = compass.scaleY = scale;

        playerHeight = new PlayerHeight();
        playerHeight.x = 18 * scale;
        playerHeight.y = bitmap.height;
        playerHeight.scaleX = playerHeight.scaleY = scale;

        label = new TextField();
        var textFormat = new TextFormat("_sans", Std.int(14 * scale));
        label.setTextFormat(textFormat);
        label.backgroundColor = 0;
        label.textColor = 0xffffff;
        label.x = 24 * scale;
        label.y = bitmap.height;
        label.width = bitmap.width - 20 * scale;
        label.height = 16 * scale;

        var background = new Shape();
        background.graphics.beginFill(0x000000);
        background.graphics.drawRect(0, 0, bitmap.width, bitmap.height + label.height);
        background.graphics.endFill();
        background.alpha = 0.2;

        addChild(background);
        addChild(bitmap);
        addChild(playerHeading);
        addChild(compass);
        addChild(playerHeight);
        addChild(label);
    }

    public function setPosition(x:Int, y:Int) {
        var dirty = currentX != x || currentY != y;
        currentX = x;
        currentY = y;

        if (dirty) {
            drawPlacements();
            label.text = '$currentX, $currentY';
        }
    }

    public function setRotation(angle:Float) {
        compass.rotation = angle;
        playerHeading.rotation = -angle;
    }

    public function setHeight(height:Float) {
        playerHeight.setPlayerHeight(height);
    }

    function drawPlacements() {
        bitmap.bitmapData.lock();
        for (x in 0...40) {
            for (y in 0...40) {
                var pixelX = currentX - 20 + x;
                var pixelY = currentY - 20 + y;
                if (pixelX >= 0 && pixelX < Placements.WIDTH &&
                        pixelY >= 0 && pixelY < Placements.WIDTH) {
                    var color = placements.getColor(pixelX, pixelY);
                    bitmap.bitmapData.setPixel(x, y, color);
                } else {
                    bitmap.bitmapData.setPixel(x, y, 0xdddddd);
                }
            }
        }
        bitmap.bitmapData.unlock();
    }
}
