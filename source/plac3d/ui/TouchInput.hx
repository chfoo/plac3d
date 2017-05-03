package plac3d.ui;

import openfl.events.TouchEvent;
import plac3d.gfx.Screen;
import openfl.events.MouseEvent;
import openfl.events.Event;
import plac3d.gfx.VirtualJoystick;
import openfl.display.Stage;

class TouchInput extends MouseInput {
    var virtualJoystick:VirtualJoystick;
    var virtualJoystickMove = false;
    var virtualJoystickTouchId:Int;
    public var virtualJoystickX(default, null) = 0.0;
    public var virtualJoystickY(default, null) = 0.0;

    public function new(stage:Stage) {
        super(stage);

        virtualJoystick = new VirtualJoystick(60 * Screen.getPixelScale());

        stage.addChild(virtualJoystick);

        stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginCallback);
        stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveCallback);
        stage.addEventListener(TouchEvent.TOUCH_END, touchEndCallback);

        stage.addEventListener(Event.RESIZE, function (event:Event) {
            layoutVirtualJoystick();
        });
        layoutVirtualJoystick();
    }

    function layoutVirtualJoystick() {
        virtualJoystick.x = 4 * Screen.getPixelScale();
        virtualJoystick.y = stage.stageHeight - virtualJoystick.diameter - 4 * Screen.getPixelScale();
    }

    override function mouseDownCallback(event:MouseEvent) {
        if (event.target == virtualJoystick) {
            startVirtualJoystickMove(event.stageX, event.stageY);
        } else {
            if (isOutsideScreenSwipe(event.stageX, event.stageY)) {
                return;
            }
            super.mouseDownCallback(event);
        }
        trace("mouse down", event.target);
    }

    function touchBeginCallback(event:TouchEvent) {
        if (event.target == virtualJoystick) {
            virtualJoystickTouchId = event.touchPointID;
            startVirtualJoystickMove(event.stageX, event.stageY);
        } else {
            if (isOutsideScreenSwipe(event.stageX, event.stageY)) {
                return;
            }
            startMove(event.stageX, event.stageY);
        }
        trace("touch begin", event.target);
    }

    function isOutsideScreenSwipe(x:Float, y:Float) {
        var threshold = 4 * Screen.getPixelScale();
        return x < threshold || x > stage.width - threshold ||
            y < threshold || y > stage.height - threshold;
    }

    function startVirtualJoystickMove(x:Float, y:Float) {
        virtualJoystickMove = true;
        virtualJoystickX = x;
        virtualJoystickY = y;
        processVirtualJoystickMove(x, y);
    }

    override function mouseUpCallback(event:MouseEvent) {
        if (event.target == virtualJoystick && virtualJoystickMove) {
            stopVirtualJoystickMove();
        } else if (moving) {
            super.mouseUpCallback(event);
        }

        trace("mouse up", event.target);
    }

    function touchEndCallback(event:TouchEvent) {
        if (event.touchPointID == virtualJoystickTouchId) {
            virtualJoystickTouchId = -1;
            stopVirtualJoystickMove();
        } else {
            stopMove();
        }

        trace("touch end", event.target);
    }

    function stopVirtualJoystickMove() {
        virtualJoystickMove = false;
        virtualJoystick.setPosition(0, 0);
        virtualJoystickX = virtualJoystickY = 0.0;
    }

    override function mouseMoveCallback(event:MouseEvent) {
        if (event.target == virtualJoystick) {
            processVirtualJoystickMove(event.stageX, event.stageY);
        } else {
            super.mouseMoveCallback(event);
        }
    }

    function touchMoveCallback(event:TouchEvent) {
        if (event.touchPointID == virtualJoystickTouchId) {
            processVirtualJoystickMove(event.stageX, event.stageY);
        } else {
            processMove(event.stageX, event.stageY);
        }
    }

    function processVirtualJoystickMove(x:Float, y:Float) {
        if (virtualJoystickMove) {
            var localX = x - virtualJoystick.x;
            var localY = y - virtualJoystick.y;
            var radius = virtualJoystick.diameter / 2;
            var x = (localX - radius) / radius;
            var y = (localY - radius) / radius;
            x = Math.min(1, Math.max(-1, x));
            y = Math.min(1, Math.max(-1, y));
            virtualJoystick.setPosition(x, y);
            virtualJoystickX = x;
            virtualJoystickY = y;
        }
    }
}
