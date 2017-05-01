package plac3d.ui;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.Stage;

class KeyInput {
    public var up(default, null) = false;
    public var down(default, null) = false;
    public var left(default, null) = false;
    public var right(default, null) = false;

    public function new(stage:Stage) {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownCallback);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyUpCallback);
    }

    function keyDownCallback(event:KeyboardEvent) {
        switch (event.keyCode) {
            case Keyboard.UP, Keyboard.W:
                up = true;
            case Keyboard.DOWN, Keyboard.S:
                down = true;
            case Keyboard.LEFT, Keyboard.A:
                left = true;
            case Keyboard.RIGHT, Keyboard.D:
                right = true;
        }
    }

    function keyUpCallback(event:KeyboardEvent) {
        switch (event.keyCode) {
            case Keyboard.UP, Keyboard.W:
                up = false;
            case Keyboard.DOWN, Keyboard.S:
                down = false;
            case Keyboard.LEFT, Keyboard.A:
                left = false;
            case Keyboard.RIGHT, Keyboard.D:
                right = false;
        }
    }

    public function update() {

    }
}
