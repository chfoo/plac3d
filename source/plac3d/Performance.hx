package plac3d;


import openfl.Lib;
import openfl.events.Event;
import openfl.Vector;
import openfl.display.Stage;

class Performance {
    static var FPS = 60;
    static var MEDIUM_FPS = 30;
    static var IDLE_FPS = 15;
    static var MAX_FRAME_RATE_CHANGE = 10;
    var stage:Stage;
    var deltas:Vector<Int>;
    var deltaIndex = 0;
    var previousTimestamp = 0;
    var currentFPS = FPS;
    var measuringCount = -1;
    var _autoFrameRate = false;
    var frameRateChangeCount = 0;

    public var adaptiveFrameRate(get, set):Bool;

    public function new(stage:Stage) {
        this.stage = stage;
        deltas = new Vector<Int>(128, true);
        deltas[0] = 0;

        stage.addEventListener(Event.ENTER_FRAME, frameEnterCallback);
    }

    function frameEnterCallback(event:Event) {
        var oldTime = previousTimestamp;
        var newTime = Lib.getTimer();
        var delta = newTime - oldTime;

        if (oldTime != 0) {
            deltaIndex += 1;

            if (deltaIndex >= deltas.length) {
                deltaIndex = 0;
            }

            deltas[deltaIndex] = delta;
        }

        previousTimestamp = newTime;

        if (measuringCount > 0) {
            measuringCount -= 1;
        } else if (measuringCount == 0) {
            measuringCount -= 1;
            var average = averageDelta();

            trace("Average delta:", average);

            if (currentFPS == FPS && average >= 18) {
                stage.frameRate = currentFPS = MEDIUM_FPS;
                trace("Lowering framerate");
                frameRateChangeCount += 1;
            } else if (currentFPS == MEDIUM_FPS && average <= 33
                    && frameRateChangeCount < MAX_FRAME_RATE_CHANGE) {
                stage.frameRate = currentFPS = FPS;
                trace("Increasing framerate");
                frameRateChangeCount += 1;
            }

            if (_autoFrameRate) {
                measureAndApply();
            }
        }
    }

    function averageDelta():Int {
        var count = 0;
        var sum = 0;

        for (index in 0...deltas.length) {
            if (deltas[index] != 0) {
                sum += deltas[index];
                count += 1;
            }
        }

        if (count == 0) {
            return 0;
        }

        return Std.int(sum / count);
    }

    public function getTimestepScale():Float {
        return FPS / stage.frameRate;
    }

    public function measureAndApply() {
        measuringCount = deltas.length;
    }

    public function set_adaptiveFrameRate(enable:Bool):Bool {
        if (enable && !_autoFrameRate) {
            measureAndApply();
        }
        _autoFrameRate = enable;
        return enable;
    }

    public function get_adaptiveFrameRate():Bool {
        return _autoFrameRate;
    }
}
