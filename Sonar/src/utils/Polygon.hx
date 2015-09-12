package utils;

import gml.vector.Vec2f;

class Polygon
{
    @:isVar public var verts ( default, default ) : Array<Vec2f>;

    public function new( verts : Array<Vec2f> ) {
        this.verts = verts;
    }

}
