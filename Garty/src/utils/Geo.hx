package utils;

/**
 * ...
 * @author ...
 */

// this is a general representation of a 2D intersection test.
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

    // if applicable, returns the point or line of intersection between a line segment and a circle
    public static function lineCircleIntersect( circle : { center : Vec2, radius : Float }, line : { a : Vec2, b : Vec2 } ) : IntersectResult {
        // distance (from line to center of circle) squared
        var rsq = circle.radius * circle.radius;
        var res: IntersectResult;

        // There are three general cases: (A) both endpoints of line are inside circle
        //                                (B) both endpoints of line are outside circle
        //                                (C) one endpoint is inside circle; one endpoint is outside circle

        // (A) clean case: line segment is completely inside the circle
        if ( line.a.sub( circle.center ).lengthsq() < rsq && line.b.sub( circle.center ).lengthsq() < rsq ) {
            res = Line( line.a, line.b );
        } else if ( line.a.sub( circle.center ).lengthsq() > rsq && line.b.sub( circle.center ).lengthsq() > rsq ) {
            // (B) also relatively clean: endpoints of line segment completely outside the circle. Treat it like an infinite line.
            var p : Vec2 = Math2.getCloseIntersectPoint( circle.center, line ); // cp (c = circle.center) must be perpendicular to line ab
            var dsq = p.sub( circle.center ).lengthsq();

            // There are three cases:
            if ( Math.abs( dsq - rsq ) < Math2.EPSILON ) { // 1. (very rare) line lies tangent to circle
                res = Point(p);
            } else if ( dsq < rsq ) { // 2. line lies secant to circle
                // this means that point p bisects the line formed by connecting the two secant points
                // to obtain the secant points, notice that if we extend a line from the center of the
                // circle to both secant points, two identical right triangles are formed, where the
                // hypotenuse is r and the shared side has length d (sqrt(dsq))

                // we can acquire the secant points by applying the Pythagorean theorem and
                // finding the length of the third side, which can be used to construct a vector
                // from p to either secant points.

                // dsec is the magnitude of vectors from p to either secant points
                var dsec = Math.sqrt( rsq - dsq );

                var pa : Vec2 = line.a.sub( p );
                var pb : Vec2 = line.b.sub( p );

                res = Line( p.add( pa.normalize().mul( dsec ) ), p.add( pb.normalize().mul( dsec ) ) );
            } else { // 3. line is completely outside the circle
                res = None;
            }
        } else {
            // (C) this is the dirtiest case: the line segment is partially inside the circle.

            // generic function to find point s, which lines on line pIn -> pOut and on the circumference of the circle
            function getIntersectPointBetween( pIn : Vec2, pOut : Vec2 ) {
                var p = pIn, q = pOut; // simpler names

                var pc = circle.center.sub( p );
                var pq = q.sub( p );

                // construct point t; ct is perpendicular to the infinite line described by points p, q
                var r : Float = pc.dot( pq.normalize() );
                var t : Vec2 = p.add( pq.normalize().mul( r ) );

                trace( "p: " + p + ", q: " + q + ", t: " + t );

                // now use Pythagorean theorem to get the magnitude of vector from t to point s, which is the point on the circle and the line segment pq
                var ct : Vec2 = t.sub( circle.center );
                var mag : Float = Math.sqrt( rsq - ct.lengthsq() );

                // finally, construct fabled point s
                var s : Vec2 = p.add( pq.normalize().mul( mag ) );

                return s;
            }

            if ( line.a.sub( circle.center ).lengthsq() < rsq ) {
                res = Line( line.a, getIntersectPointBetween( line.a, line.b ) );
            } else { // line.b.sub( circle.center ).lengthsq() < rsq
                res = Line( line.b, getIntersectPointBetween( line.b, line.a ) );
            }

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
