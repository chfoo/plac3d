package plac3d;

import openfl.geom.Matrix3D;
import away3d.core.base.SubMesh;
import away3d.core.base.Geometry;
import away3d.containers.ObjectContainer3D;
import away3d.tools.commands.Merge;
import away3d.materials.methods.HardShadowMapMethod;
import away3d.lights.LightBase;
import away3d.materials.lightpickers.LightPickerBase;
import away3d.containers.View3D;
import away3d.materials.ColorMaterial;
import away3d.primitives.CubeGeometry;
import openfl.Vector;
import away3d.entities.Mesh;


class PixelMesh {
    static var CLUSTER_WIDTH = 16;
    static public var CUBE_WIDTH = 100;

    var view:View3D;
    var placements:Placements;
    var cubeGeometry:CubeGeometry;
    var materials:Vector<ColorMaterial>;

    // Clusters are arranged visually as surrounding the current position:
    // 0 1 2
    // 3 4 5
    // 6 7 8
    // The center index 4 is the current position.
    var clusters:Vector<Mesh>;

    var currentClusterX:Int;
    var currentClusterY:Int;

    public function new(view:View3D, placements:Placements) {
        this.view = view;
        this.placements = placements;

        cubeGeometry = new CubeGeometry();
        cubeGeometry.tile6 = false;
        materials = new Vector<ColorMaterial>();

        for (index in 0...ColorTable.COLOR.length) {
            materials[index] = new ColorMaterial(ColorTable.COLOR[index]);
            materials[index].specular = 0.2;
        }

        clusters = new Vector<Mesh>(9);
        currentClusterX = currentClusterY = 0;

        initClusters();
    }

    public function applyShading(lightPicker:LightPickerBase, shadowLight:LightBase) {
        for (material in materials) {
            material.lightPicker = lightPicker;
            material.shadowMethod = new HardShadowMapMethod(shadowLight);
            material.shadowMethod.alpha = 0.5;
            material.shadowMethod.epsilon = 0.25;
        }
    }

    public function getHeight(x:Int, y:Int):Float {
        var blockHeight = 3 * Math.log(placements.getFrequency(x, y) / 5 + 1) + 1;
        return blockHeight * CUBE_WIDTH;
    }

    function newPixelMesh(x:Int, y:Int, colorIndex:Int, frequency:Int):Mesh {
        var height = getHeight(x, y);
        var material = materials[colorIndex];
        #if html5
        var cube = new QuickMesh(cubeGeometry, material);
        #else
        var cube = new Mesh(cubeGeometry, material);
        #end

        // Cube's origin is in the center of the cube.
        // Move it so that the top-left of the cube is the origin.
        cube.scaleY = height / CUBE_WIDTH;
        cube.x = x * CUBE_WIDTH + CUBE_WIDTH / 2;
        cube.z = -y * CUBE_WIDTH - CUBE_WIDTH / 2;
        cube.y = height / 2;

        return cube;
    }

    function newCluster(clusterX:Int, clusterY:Int):Mesh {
        var bigMesh = new Mesh(new Geometry());
        var merger = new Merge(true);
        var meshContainer = new ObjectContainer3D();
        var startX = clusterX * CLUSTER_WIDTH;
        var startY = clusterY * CLUSTER_WIDTH;

        for (x in startX...startX + CLUSTER_WIDTH) {
            for (y in startY...startY + CLUSTER_WIDTH) {
                if (x >= Placements.WIDTH || y >= Placements.WIDTH) {
                    continue;
                }

                var frequency = placements.getFrequency(x, y);
                var colorIndex = placements.getColorIndex(x, y);
                var height = Math.log(frequency + 0.0001);
                var material = materials[colorIndex];
                var cube = newPixelMesh(x, y, colorIndex, frequency);
                meshContainer.addChild(cube);
            }
        }

        merger.applyToContainer(bigMesh, meshContainer);

        return bigMesh;
    }

    public function updatePosition(x:Int, y:Int) {
        var clusterX = Math.floor(x / CLUSTER_WIDTH);
        var clusterY = Math.floor(y / CLUSTER_WIDTH);

        if (clusterX == currentClusterX - 1) {
            shiftClusters([0, 3, 6], [1, 4, 7], [2, 5, 8]);
        } else if (clusterX == currentClusterX + 1) {
            shiftClusters([2, 5, 8], [1, 4, 7], [0, 3, 6]);
        } else if (clusterX != currentClusterX) {
            clearClusters();
        }

        if (clusterY == currentClusterY - 1) {
            shiftClusters([0, 1, 2], [3, 4, 5], [6, 7, 8]);
        } else if (clusterY == currentClusterY + 1) {
            shiftClusters([6, 7, 8], [3, 4, 5], [0, 1, 2]);
        } else if (clusterY != currentClusterY) {
            clearClusters();
        }

        var dirty = clusterX != currentClusterX || clusterY != currentClusterY;
        currentClusterX = clusterX;
        currentClusterY = clusterY;

        if (dirty) {
            for (index in 0...9) {
                if (clusters[index] == null) {
                    initCluster(index);
                }
            }
        }
    }

    function initClusters() {
        for (index in 0...9) {
            initCluster(index);
        }
    }

    function initCluster(clusterIndex:Int) {
        var clusterX = clusterIndex % 3 - 1 + currentClusterX;
        var clusterY = Math.floor(clusterIndex / 3) - 1 + currentClusterY;

        if (clusterX >= 0 && clusterY >= 0) {
            clusters[clusterIndex] = newCluster(clusterX, clusterY);
            view.scene.addChild(clusters[clusterIndex]);
        }
    }

    function shiftClusters(first:Array<Int>, second:Array<Int>, third:Array<Int>) {
        // third -> null
        for (thirdIndex in third) {
            if (clusters[thirdIndex] != null) {
                view.scene.removeChild(clusters[thirdIndex]);
            }
        }

        // second -> third
        for (index in 0...3) {
            clusters[third[index]] = clusters[second[index]];
        }

        // first -> second
        for (index in 0...3) {
            clusters[second[index]] = clusters[first[index]];
        }

        // null -> first
        for (index in 0...3) {
            clusters[first[index]] = null;
        }
    }

    function clearClusters() {
        for (index in 0...9) {
            if (clusters[index] != null) {
                view.scene.removeChild(clusters[index]);
                clusters[index] = null;
            }
        }
    }
}
