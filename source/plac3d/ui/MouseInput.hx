package plac3d.ui;

#if html5
import js.html.PointerEvent;
import js.Browser;
#end
import openfl.events.MouseEvent;
import openfl.display.Stage;


class MouseInput {
    public var xMovement(default, null) = 0.0;
    public var yMovement(default, null) = 0.0;

    var stage:Stage;

    var pendingXMovement = 0.0;
    var pendingYMovement = 0.0;

    var moving = false;
    var movingOriginX:Float;
    var movingOriginY:Float;

    var pointerLocked = false;

    public function new(stage:Stage) {
        this.stage = stage;

        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownCallback);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpCallback);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveCallback);

        #if html5
        var container = Browser.document.getElementById("openfl-content");
        container.addEventListener("mousedown", pointerLockClickCallback);
        Browser.document.addEventListener("pointerlockchange", pointerLockChangeCallback);
        container.addEventListener("mousemove", pointerLockMoveCallback);
        #end
    }

    function mouseDownCallback(event:MouseEvent) {
        startMove(event.stageX, event.stageY);
    }

    function startMove(x:Float, y:Float) {
        moving = true;
        movingOriginX = x;
        movingOriginY = y;
    }

    function mouseUpCallback(event:MouseEvent) {
        stopMove();
    }

    function stopMove() {
        moving = false;
    }

    function mouseMoveCallback(event:MouseEvent) {
        processMove(event.stageX, event.stageY);
    }

    function processMove(x:Float, y:Float) {
        if (moving) {
            pendingXMovement += movingOriginX - x;
            pendingYMovement += movingOriginY - y;
            movingOriginX = x;
            movingOriginY = y;
        }
    }

    #if html5
    function pointerLockClickCallback(event:js.html.MouseEvent) {
        if (!pointerLocked) {
            var container = Browser.document.getElementById("openfl-content");
            container.requestPointerLock();
        }
    }

    function pointerLockMoveCallback(event:js.html.MouseEvent) {
        if (pointerLocked) {
            pendingXMovement += event.movementX;
            pendingYMovement += event.movementY;
        }
    }

    function pointerLockChangeCallback(event:PointerEvent) {
        var container = Browser.document.getElementById("openfl-content");
        pointerLocked = Browser.document.pointerLockElement == container;
    }
    #end

    public function update() {
        xMovement = pendingXMovement;
        yMovement = pendingYMovement;
        pendingXMovement = 0;
        pendingYMovement = 0;
    }
}
