package plac3d;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import flash.display.BitmapData;
import openfl.Assets;
import away3d.textures.BitmapCubeTexture;
import away3d.primitives.SkyBox;
import away3d.primitives.CubeGeometry;
import openfl.events.MouseEvent;
import openfl.display.StageDisplayState;
import motion.easing.Quad;
import plac3d.gfx.HelpOverlay;
import plac3d.gfx.Screen;
import plac3d.ui.TouchInput;
import plac3d.ui.KeyInput;
import openfl.geom.Vector3D;
import plac3d.gfx.Minimap;
import openfl.display.Shape;
import motion.Actuate;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.lights.DirectionalLight;
import away3d.controllers.FirstPersonController;
import away3d.materials.ColorMaterial;
import away3d.debug.AwayStats;
import openfl.events.Event;
import away3d.primitives.PlaneGeometry;
import away3d.entities.Mesh;
import away3d.containers.View3D;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.Sprite;
import Random;

class Scene extends Sprite {
    static public var PIXEL_CANVAS_WIDTH = 1000;
    static public var PIXEL_CANVAS_HEIGHT = 1000;

    var view:View3D;
    var plane:Mesh;
    var placements:Placements;
    var keyInput:KeyInput;
    var touchInput:TouchInput;
    var cameraController:FirstPersonController;
    var pixelMesh:PixelMesh;
    var currentIndexX:Int;
    var currentIndexY:Int;
    var currentPlayerHeight:Float;
    var lightPicker:StaticLightPicker;
    var crosshair:Shape;
    var minimap:Minimap;
    var helpOverlay:HelpOverlay;
    var stats:AwayStats;
    var skyBox:SkyBox;
    var performance:Performance;

    public function new(parent:Sprite) {
        super();
        parent.addChild(this);

        view = new View3D();
        view.backgroundColor = 0xdddddd;
        #if html5
        view.depthPrepass = false;
        #end
        addChild(view);
        performance = new Performance(stage);

        keyInput = new KeyInput(stage);
        touchInput = new TouchInput(stage);
        placements = new Placements();
        pixelMesh = new PixelMesh(view, placements);
        lightPicker = new StaticLightPicker([]);

        initOverlay();

        plane = new Mesh(
            new PlaneGeometry(700, 700),
            new ColorMaterial()
        );
        view.scene.addChild(plane);

        addEventListener(Event.ENTER_FRAME, enterFrameCallback);
        stage.addEventListener(Event.RESIZE, resizeCallback);

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        initEnvironment();
        initCamera();
        initLights();
        initCurrentPixels();
        resizeViewToStage();

        #if desktop
        enterFullscreen();
        #end

        performance.adaptiveFrameRate = true;
    }

    function initEnvironment() {
        var size = 64;
        var envmap = Assets.getBitmapData("assets/skybox_envmap.png");
        var top = new BitmapData(size, size);
        var middle = new BitmapData(size, size);
        var bottom = new BitmapData(size, size);

        bottom.copyPixels(envmap, new Rectangle(0, size, size, size), new Point(0, 0));
        top.copyPixels(envmap, new Rectangle(size, size, size, size), new Point(0, 0));
        middle.copyPixels(envmap, new Rectangle(size * 2, size, size, size), new Point(0, 0));

        var texture = new BitmapCubeTexture(
            middle, middle, top, bottom, middle, middle
        );
        skyBox = new SkyBox(texture);

        view.scene.addChild(skyBox);
    }

    function initOverlay() {
        var scale = Screen.getPixelScale();
        crosshair = new Shape();
        crosshair.graphics.lineStyle(1, 0x000000, 0.5);
        crosshair.graphics.moveTo(0, -10);
        crosshair.graphics.lineTo(0, 10);
        crosshair.graphics.moveTo(-10, 0);
        crosshair.graphics.lineTo(10, 0);
        crosshair.scaleX = crosshair.scaleY = scale;

        minimap = new Minimap(placements, Std.int(80 * scale));

        helpOverlay = new HelpOverlay();
        helpOverlay.y = 0;
        helpOverlay.scaleX = helpOverlay.scaleY = 0.5 * scale;
        helpOverlay.width = helpOverlay.height = Math.min(
            helpOverlay.width, Math.min(stage.width * 0.7, stage.height * 0.7)
        );

        minimap.addEventListener(MouseEvent.CLICK, function (event:MouseEvent) {
            if (stats == null) {
                stats = new AwayStats(view);
                view.stage.addChild(stats);
            }
        });

        view.stage.addChild(crosshair);
        view.stage.addChild(minimap);
        view.stage.addChild(helpOverlay);
    }

    function initLights() {
        var lightTopLeft = new DirectionalLight(1, -1, -1);
        lightTopLeft.ambient = 0.1;
        lightTopLeft.specular = 1.0;
        lightTopLeft.diffuse = 0.8;
        lightTopLeft.castsShadows = true;
        view.scene.addChild(lightTopLeft);

        var lightBottomRight = new DirectionalLight(-1, -1, 1);
        lightBottomRight.ambient = 0.1;
        lightBottomRight.specular = 0.1;
        lightBottomRight.diffuse = 0.8;
        view.scene.addChild(lightBottomRight);

        lightPicker.lights = [lightTopLeft, lightBottomRight];
        pixelMesh.applyShading(lightPicker, lightTopLeft);
    }

    function initCamera() {
        cameraController = new FirstPersonController(view.camera);
        cameraController.steps = 0;
        cameraController.panAngle = Random.float(0, 360);
        cameraController.tiltAngle = 0;
//        cameraController.fly = true;

        view.camera.x = 0;
        view.camera.z = 0;
        currentPlayerHeight = view.camera.y = 1000;
        view.camera.lens.far += 1000;
    }

    function enterFrameCallback(event:Event) {
        keyInput.update();
        touchInput.update();

        updateInput();
        updatePixels();
        updateView();

        view.render();

        keyInput.clear();
        touchInput.clear();
    }

    function resizeCallback(event:Event) {
        resizeViewToStage();
    }

    function resizeViewToStage() {
        view.width = stage.stageWidth;
        view.height = stage.stageHeight;

        crosshair.x = stage.stageWidth / 2;
        crosshair.y = stage.stageHeight / 2;

        minimap.x = stage.stageWidth - minimap.width;
        minimap.y = 0;

        helpOverlay.x = stage.stageWidth / 2 - helpOverlay.width / 2;
    }

    function initCurrentPixels() {
        currentIndexX = Math.floor(view.camera.x / PixelMesh.CUBE_WIDTH);
        currentIndexY = Math.floor(-view.camera.z / PixelMesh.CUBE_WIDTH);
        pixelMesh.updatePosition(currentIndexX, currentIndexY);
    }

    public function setPosition(x:Int, y:Int) {
        currentIndexX = x;
        currentIndexY = y;
        view.camera.x = x * PixelMesh.CUBE_WIDTH;
        view.camera.z = -y * PixelMesh.CUBE_WIDTH;
    }

    function updateInput() {
        var timestepScale = performance.getTimestepScale();

        if (keyInput.up || touchInput.virtualJoystickY < -0.5) {
            cameraController.incrementWalk(10 * timestepScale);
        } else if (keyInput.down || touchInput.virtualJoystickY > 0.5) {
            cameraController.incrementWalk(-10 * timestepScale);
        }

        if (keyInput.left || touchInput.virtualJoystickX < -0.5) {
            cameraController.incrementStrafe(-10 * timestepScale);
        } else if (keyInput.right || touchInput.virtualJoystickX > 0.5) {
            cameraController.incrementStrafe(10 * timestepScale);
        }

        if (helpOverlay.visible && (keyInput.up || keyInput.down ||
                keyInput.left || keyInput.right ||
                touchInput.xMovement != 0 || touchInput.yMovement != 0 ||
                touchInput.virtualJoystickX != 0 || touchInput.virtualJoystickY != 0
                )) {
            helpOverlay.visible = false;
        }

        var scale = Screen.getPixelScale();
        var mouseScale = 0.1;

        if (scale >= 2) {
            mouseScale /= Math.sqrt(scale - 1);
        }

        cameraController.panAngle += touchInput.xMovement * mouseScale;
        cameraController.tiltAngle += touchInput.yMovement * mouseScale;
        minimap.setRotation(-cameraController.panAngle);

        processFullscreen();
    }

    function updatePixels() {
        var newIndexX = Math.floor(view.camera.x / PixelMesh.CUBE_WIDTH);
        var newIndexY = Math.floor(-view.camera.z / PixelMesh.CUBE_WIDTH);

        currentIndexX = newIndexX;
        currentIndexY = newIndexY;

        pixelMesh.updatePosition(currentIndexX, currentIndexY);
    }

    function updateView() {
        var newCameraHeight;
        if (currentIndexX >= 0 && currentIndexX < PIXEL_CANVAS_WIDTH &&
            currentIndexY >=0 && currentIndexY < PIXEL_CANVAS_WIDTH) {
            newCameraHeight = pixelMesh.getHeight(currentIndexX, currentIndexY) + PixelMesh.CUBE_WIDTH * 1.5;
        } else {
            newCameraHeight = 0;
        }

        if (currentPlayerHeight != newCameraHeight && !cameraController.fly) {
            Actuate.tween(view.camera, 1.0, {y: newCameraHeight}).ease(Quad.easeInOut);
            currentPlayerHeight = newCameraHeight;

        }

        minimap.setHeight(view.camera.y / PixelMesh.CUBE_WIDTH / 20);
        minimap.setPosition(currentIndexX, currentIndexY);
    }

    function processFullscreen() {
        if (keyInput.escapePressed) {
            touchInput.exitPointerLock();
            exitFullscreen();
        }
        if (keyInput.fullscreenPressed) {
            touchInput.exitPointerLock();
            toggleFullscreen();
        }

    }

    function enterFullscreen() {
        trace("enter fullscreen");
        stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
    }

    function exitFullscreen() {
        trace("exit fullscreen");
        stage.displayState = StageDisplayState.NORMAL;
    }

    function toggleFullscreen() {
        if (stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            enterFullscreen();
        } else {
            exitFullscreen();
        }
    }
}
