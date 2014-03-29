package utils;

class Polygon
{
    @:isVar public var verts ( default, default ) : Array<Vec2>;

    public function new( verts : Array<Vec2> ) {
        this.verts = verts;
    }

}
