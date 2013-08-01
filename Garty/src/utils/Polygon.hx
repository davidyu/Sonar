package utils;

class Polygon
{
    @:isVar public var edges ( default, default ) : Array<Vec2>;

    public function new( edgesList : Array<Vec2> ) {
        this.edges = edgesList;
    } 

}
