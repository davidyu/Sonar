package utils;

/**
 * ...
 * @author ...
 */
class Geo
{
    
    public static function isPointinPolygon( poly : Polygon, point : Vec2 ) : Bool {
        var edges = poly.edges;
        var c = false;
        var i = 0;
        var j = edges.length - 1;
        
        while ( i < edges.length ) {
            if ( ( edges[i].y > point.y ) != ( edges[j].y > point.y ) &&
                 ( point.x < ( edges[j].x - edges[i].x ) * ( point.y - edges[i].y ) 
                           / ( edges[j].y - edges[i].y ) + edges[i].x ) ) {
               // Inverting "counts" odd/even # of intersections 
               c = !c;
            }
            j = i++;
        }
        
        return c;
    }
    
    public static function getClosestPoint( poly : Polygon, point : Vec2 ) : Vec2 {
        var edges = poly.edges;
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
    
    public static function getLineIntersection( polys : Polygon, p1 : Vec2, p2 : Vec2 ) : Vec2 {
        var edges = polys.edges;
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
    
    public static function minTransCirclePolygon( poly : Polygon, circle : { pos : Vec2, radius : Float } ) : Vec2 {
        
        var edges = poly.edges;
        var i = 0;
        var length = edges.length;
        var j = length - 1;
        var radsq = circle.radius * circle.radius;
        var delta = new Vec2();
        var iter = 10;
        var center = new Vec2();
        var centerp = new Vec2( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY );
        
        while ( --iter > 0 && center.sub( centerp ).lengthsq() > 0.0001 ) {
            center.set( centerp );
            while ( i < length ) {
                var d = Math2.getCloseIntersectPoint( center, edges[i], edges[j] ).sub( center );
                if ( d.lengthsq() < radsq ) {
                    delta = delta.add( d.normalize().mul( -circle.radius + d.length() ) );
                }
                j = i++;
            }
            i = 0;
            j = length -1;
            centerp = circle.pos.add( delta );
        }
        return delta;
    }
    
    public static function transform( poly : Polygon, v : Vec2 ) : Polygon {
        var edges = poly.edges;
        var newEdges = new Array<Vec2>();
        
        for ( e in edges ) {
            newEdges.push( e.clone().add( v ) );
        }
        
        return new Polygon( newEdges );
    }
}
