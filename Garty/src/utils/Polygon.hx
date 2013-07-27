package utils;

class Polygon
{
    @:isVar public var edges ( default, default ) : Array<Vec2>;

    public function new( edgesList : Array<Vec2> ) {
        this.edges = edgesList;
    }
    
    public function getLineIntersection( p1 : Vec2, p2 : Vec2 ) : Vec2 {
        var i = 0;
        var j = edges.length - 1;
        var intersect : Vec2 = null;
        
        while ( i < edges.length ) {
            intersect = Math2.getLineLineIntersection( p1, p2, edges[i], edges[j] );
            if ( intersect != null ) {
                return intersect;
            }
            j = i++;
        }
        
        return null;
    }

    public function isPointinPolygon( point : Vec2 ) : Bool {
        var c = false;
        var i = 0;
        var j = edges.length - 1;
        
        while ( i < edges.length ) {
            if ( ( edges[i].y > point.y ) != ( edges[j].y > point.y ) &&
                 ( point.x <= ( edges[j].x - edges[i].x ) * ( point.y - edges[i].y ) 
                           / ( edges[j].y - edges[i].y ) + edges[i].x ) ) {
               // Inverting "counts" odd/even # of intersections 
               c = !c;
            }
            j = i++;
        }
        
        return c;
    }
    
    public function getClosestPoint( point : Vec2 ) : Vec2 {
        var i = 0;
        var j = edges.length - 1;
        var closest : Vec2 = new Vec2( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY );
        var ext : Vec2;
        var len : Float;
        var minLen = Math.POSITIVE_INFINITY;
        
        while ( i < edges.length ) {
            ext = Math2.getCloseIntersectPoint( point, edges[i], edges[j] );
            len = ext.sub( point ).lengthsq();
            if ( len < minLen ) {
                closest = ext;
                minLen = len;
            }
        
            j = i++;
        }
        
        return closest;
    }
    

    

}