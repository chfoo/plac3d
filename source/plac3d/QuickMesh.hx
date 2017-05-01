package plac3d;

import away3d.core.base.ISubGeometry;
import openfl.Vector;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;


class QuickMesh extends Mesh {
    override function set_geometry(value:Geometry):Geometry {
        // addEventListener is slow on html5 so comment it out since
        // we aren't using the mesh in a scene :)
        var i:Int;

        if (_geometry != null) {
//            _geometry.removeEventListener(GeometryEvent.BOUNDS_INVALID, onGeometryBoundsInvalid);
//            _geometry.removeEventListener(GeometryEvent.SUB_GEOMETRY_ADDED, onSubGeometryAdded);
//            _geometry.removeEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED, onSubGeometryRemoved);

            for (i in 0..._subMeshes.length)
                _subMeshes[i].dispose();
            _subMeshes.length = 0;
        }

        _geometry = value;
        if (_geometry != null) {
//            _geometry.addEventListener(GeometryEvent.BOUNDS_INVALID, onGeometryBoundsInvalid);
//            _geometry.addEventListener(GeometryEvent.SUB_GEOMETRY_ADDED, onSubGeometryAdded);
//            _geometry.addEventListener(GeometryEvent.SUB_GEOMETRY_REMOVED, onSubGeometryRemoved);

            var subGeoms:Vector<ISubGeometry> = _geometry.subGeometries;

            for (i in 0...subGeoms.length)
                addSubMesh(subGeoms[i]);
        }

        if (_material != null) {
            // reregister material in case geometry has a different animation
            _material.removeOwner(this);
            _material.addOwner(this);
        }

        return value;
    }
}
