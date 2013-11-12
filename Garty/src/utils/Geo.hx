package utils;

/**
 * ...
 * @author ...
 */

// this is a general representation of an intersection test.
enum IntersectResult {
    None;
    Point(point: Vec2);
    Line(a:Vec2, b:Vec2);
}

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
            ext = Math2.getCloseIntersectPoint( point, { a: edges[i], b: edges[j] } );
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

    // if applicable, returns the point/line of intersection between a line segment and a circle
    public static function lineCircleIntersect( circle : { center : Vec2, radius : Float }, line : { a : Vec2, b : Vec2 } ) : IntersectResult {
        var p : Vec2 = Math2.getCloseIntersectPoint( circle.center, line );
        // distance (from line to center of circle) squared
        var dsq = Math2.getCloseIntersectPoint( circle.center, line ).sub( circle.center ).lengthsq();
        var rsq = circle.radius * circle.radius;
        var res: IntersectResult;

        if ( dsq < rsq ) { // line lies secant to circle
            // to construct the secant points, notice that if we extend a line from the
            // center to both secant points, two identical right triangles are formed, where the
            // hypotenuse is r and the shared side has length d (sqrt(dsq))

            // we can acquire the secant points by applying the Pythagorean theorem and
            // finding the length of the third side, which can be used to construct a vector
            // from p to either secant points.

            // dsec is the magnitude of vectors from p to either secant points
            var dsec = Math.sqrt( rsq - dsq );

            var pa : Vec2 = line.a.sub( p );
            var pb : Vec2 = line.b.sub( p );

            res = Line( p.add( pa.normalize().mul( dsec ) ), p.add( pb.normalize().mul( dsec ) ) );
        } else if ( dsq == rsq ) { // line lies tangent to circle -- this is BAD becauses it's a floating point equality comparison! Does the haxe compiler do something smart here?
            res = Point(p);
        } else { // line is outside the circle
            res = None;
        }

        return res;
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
                var d = Math2.getCloseIntersectPoint( center, { a: edges[i], b: edges[j] } ).sub( center );
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
