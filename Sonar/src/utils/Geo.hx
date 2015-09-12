package utils;

import gml.vector.Vec2f;

/**
 * ...
 * @author ...
 */

// this is a general representation of a 2D intersection test.
enum IntersectResult {
    None;
    Point(point: Vec2f);
    Line(a:Vec2f, b:Vec2f);
}

class Geo
{
    public static function isPointinPolygon( poly : Polygon, point : Vec2f ) : Bool {
        var verts = poly.verts;
        var c = false;
        var i = 0;
        var j = verts.length - 1;

        while ( i < verts.length ) {
            if ( ( verts[i].y > point.y ) != ( verts[j].y > point.y ) &&
                 ( point.x < ( verts[j].x - verts[i].x ) * ( point.y - verts[i].y )
                           / ( verts[j].y - verts[i].y ) + verts[i].x ) ) {
               // Inverting "counts" odd/even # of intersections
               c = !c;
            }
            j = i++;
        }

        return c;
    }

    public static function getClosestPoint( poly : Polygon, point : Vec2f ) : Vec2f {
        return getClosestPointAndEdge( poly, point ).point;
    }

    public static function getClosestPointAndEdge( poly : Polygon, point : Vec2f ) : { point: Vec2f, edge: { a: Vec2f, b: Vec2f } } {
        var verts = poly.verts;
        var i = 0;
        var j = verts.length - 1;
        var closest : Vec2f = new Vec2f( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY );
        var edge : { a: Vec2f, b: Vec2f } = { a: new Vec2f( 0, 0 ), b: new Vec2f( 0, 0 ) };
        var ext : Vec2f;
        var len : Float;
        var minLen = Math.POSITIVE_INFINITY;

        while ( i < verts.length ) {
            ext = Math2.getCloseIntersectPoint( point, { a: verts[i], b: verts[j] } );
            len = ( ext -  point ).lensq();
            if ( len < minLen ) {
                closest = ext;
                edge = { a: verts[i], b: verts[j] };
                minLen = len;
            }

            j = i++;
        }

        return { point: closest, edge: edge };
    }

    public static function getLineIntersection( polys : Polygon, p1 : Vec2f, p2 : Vec2f ) : Vec2f {
        var verts = polys.verts;
        var i = 0;
        var j = verts.length - 1;
        var intersect : Vec2f = null;

        while ( i < verts.length ) {
            intersect = Math2.getLineLineIntersection( p1, p2, verts[i], verts[j] );
            if ( intersect != null ) {
                return intersect;
            }
            j = i++;
        }

        return null;
    }

    public static function isPointInCircle( circle: { center : Vec2f, radius : Float }, point: Vec2f ) : Bool {
        return ( point - circle.center ).lensq() <= circle.radius * circle.radius;
    }

    // if applicable, returns the point or line of intersection between a line segment and a circle
    public static function lineCircleIntersect( circle : { center : Vec2f, radius : Float }, line : { a : Vec2f, b : Vec2f } ) : IntersectResult {
        // distance (from line to center of circle) squared
        var rsq = circle.radius * circle.radius;
        var res: IntersectResult;

        // There are three general cases: (A) both endpoints of line are inside circle
        //                                (B) both endpoints of line are outside circle
        //                                (C) one endpoint is inside circle; one endpoint is outside circle

        // (A) clean case: line segment is completely inside the circle
        if ( ( line.a - circle.center ).lensq() < rsq && ( line.b -  circle.center ).lensq() < rsq ) {
            res = Line( line.a, line.b ); // this actually is counterintuitive to the name of the function, any sane person using this function would expect None
        } else if ( ( line.a -  circle.center ).lensq() > rsq && ( line.b - circle.center ).lensq() > rsq ) {
            // (B) also relatively clean: endpoints of line segment completely outside the circle. Treat it like an infinite line.
            var p : Vec2f = Math2.getCloseIntersectPoint( circle.center, line ); // cp (c = circle.center) must be perpendicular to line ab
            var dsq = ( p + circle.center ).lensq();

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

                var pa : Vec2f = line.a - p;
                var pb : Vec2f = line.b - p;

                res = Line( p + dsec * pa.normalize(), p + dsec * pb.normalize() );
            } else { // 3. line is completely outside the circle
                res = None;
            }
        } else {
            // (C) this is the dirtiest case: the line segment is partially inside the circle.

            // generic function to find point s, which lies on line pIn -> pOut AND on the circumference of the circle
            function getIntersectPointBetween( pIn : Vec2f, pOut : Vec2f ) {
                var p = pIn, q = pOut; // simpler names

                var pc = circle.center - p;
                var pq = q - p;

                // construct point t; ct is perpendicular to the infinite line described by points p, q
                var r : Float = pc.dot( pq.normalize() );
                var t : Vec2f = p + r * pq.normalize();

                // now use Pythagorean theorem to get the magnitude of vector from t to point s, which is the point on the circle and the line segment pq
                var ct : Vec2f = t - circle.center;
                var mag : Float = Math.sqrt( rsq - ct.lensq() );

                // finally, construct fabled point s
                var s : Vec2f = t + mag * pq.normalize();

                return s;
            }

            if ( ( line.a - circle.center ).lensq() < rsq ) {
                res = Line( line.a, getIntersectPointBetween( line.a, line.b ) );
            } else { // line.b.sub( circle.center ).lensq() < rsq
                res = Line( line.b, getIntersectPointBetween( line.b, line.a ) );
            }

        }


        return res;
    }

    public static function minTransCirclePolygon( poly : Polygon, circle : { pos : Vec2f, radius : Float } ) : Vec2f {

        var verts = poly.verts;
        var i = 0;
        var length = verts.length;
        var j = length - 1;
        var radsq = circle.radius * circle.radius;
        var delta = new Vec2f( 0, 0 );
        var iter = 10;
        var center = new Vec2f( 0, 0 );
        var centerp = new Vec2f( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY );

        while ( --iter > 0 && ( center - centerp ).lensq() > 0.0001 ) {
            center = centerp;
            while ( i < length ) {
                var d = Math2.getCloseIntersectPoint( center, { a: verts[i], b: verts[j] } ) - center;
                if ( d.lensq() < radsq ) {
                    delta = delta + ( -circle.radius + d.len() ) * d.normalize();
                }
                j = i++;
            }
            i = 0;
            j = length -1;
            centerp = circle.pos + delta;
        }
        return delta;
    }

    public static function transform( poly : Polygon, v : Vec2f ) : Polygon {
        var verts = poly.verts;
        var newVerts = new Array<Vec2f>();

        for ( v in verts ) {
            newVerts.push( 2 * v );
        }

        return new Polygon( newVerts );
    }
}
