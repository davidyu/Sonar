package utils;

enum LineLineIntersectResult {
    None; //parallel, not collinear
    Overlapping;
    Point(point: Vec2);
}

class Math2 {
    public static var PI : Float = 3.141592653589793238462643383279;
    public static var SMALL : Float = 0.00001;
    public static var EPSILON : Float = SMALL;

    public static inline function randomFloat( min : Float, max : Float ) : Float {
        return Math.random() * (max - min) + min;
    }

    public static inline function randomInt( min : Int, max : Int ) : Int {
        return Std.random( max - min ) + min;
    }

    //
    // Converts specified angle in radians to degrees.
    // @return angle in degrees (not normalized to 0...360)
    // by zlumer
    //
    public inline static function radToDeg( rad : Float ) : Float
    {
        return 180 / Math.PI * rad;
    }

    //
    // Converts specified angle in degrees to radians.
    // @return angle in radians (not normalized to 0...Math.PI*2)
    // by zlumer
    //
    public inline static function degToRad( deg : Float ) : Float
    {
        return Math.PI / 180 * deg;
    }

    //
    // "Clamps" a value to boundaries [min, max].
    // Example:
    // clamp(2, 1, 5) == 2;
    // clamp(0, 1, 5) == 1;
    // clamp(6, 1, 5) == 5;
    // by zlumer
    //
    public inline static function clamp( value : Float, min : Float, max : Float ) : Float
    {
        if ( value < min )
            return min;
        else if ( value > max )
            return max;
        else
            return value;
    }

    public static function getRayLineIntersection( ray: { origin: Vec2, direction: Vec2 }, line: { a: Vec2, b: Vec2 } ) : LineLineIntersectResult {
        // approach: let t and u be scalars, find t such that. ( origin + u ( direction ) ) = ( a + t ( b - a ) ). Insight: find t, not u

        // edge cases: if ( b - a ) x direction = 0, then the line and ray are parallel
        // if ( a - origin ) x direction = 0 also, then the line and ray are collinear: there are two more umbrella cases. See below:
        var b_a = line.b.sub( line.a );

        if ( Math.abs( b_a.cross( ray.direction ) ) < Math2.EPSILON ) { // parallel, but don't know if collinear or not
            if ( Math.abs( ray.origin.sub( line.a ).cross( ray.direction ) ) < Math2.EPSILON ) { //collinear, but don't know if overlapping or disjoint
                var oa: Vec2 = line.a.sub( ray.origin );
                var ob: Vec2 = line.b.sub( ray.origin );

                // I have a feeling this can be optimized more...
                if ( oa.dot( ob ) / oa.lengthsq() >= 0 && oa.dot( ob ) / oa.lengthsq() <= 1 &&                 // b is between a and o AND
                     Math.abs( oa.normalize().add( ray.direction.normalize() ).length() ) <= Math2.EPSILON ) { // ob is pointing away from ray.direction; so line and ray are disjoint
                    return None;
                } else { // ray overlaps line segment ab
                    return Overlapping;
                }
            } else { // parallel but not collinear; no intersection
                return None;
            }
        }

        // with ( origin + u ( direction ) ) = ( a + t ( b - a ) ), cross both sides with direction to cancel out u in the process:
        // origin x direction = a x direction + t ( b - a ) x direction
        // t = ( origin - a ) x direction / ( b - a ) x direction

        var t = ( ray.origin.sub( line.a ).cross( ray.direction ) ) / ( b_a.cross( ray.direction ) );

        // 0 <= t <= 1, otherwise the point is on the line defined by a and b rather than the line segment itself
        if ( t >= -Math2.EPSILON && t <= 1 + Math2.EPSILON  ) {
            return Point( line.a.add( b_a.mul( t ) ) );
        }

        return None;
    }

    // http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    public static function getLineLineIntersection( ap1 : Vec2, ap2 : Vec2, bp1 : Vec2, bp2 : Vec2 ) : Vec2 {
        var r = ap2.sub( ap1 );
        var s = bp2.sub( bp1 );
        var d = bp1.sub( ap1 );
        var rxs = 1 / r.cross( s );
        var t = d.cross( s.scale( rxs ) );
        var u = d.cross( r.scale( rxs ) );

        if ( 0 <= t && t <= 1 && 0 <= u && u <= 1 ) {
            return ap1.add( r.scale( t ) );
        }

        return null;
    }

    // returns the point on a line segment (a,b) that is closest to some other point p
    public static function getCloseIntersectPoint( p : Vec2, line: { a: Vec2, b : Vec2 }  ) : Vec2 {
        var ap : Vec2 = p.sub( line.a );
        var ab : Vec2 = line.b.sub( line.a );

        // r is the ratio between lengths ae / ab, where ae is ||ap||cos@
        // ae can also be thought of as the vector projection of ap onto ab.
        // r can also be thought of as the scalar projection of ap onto ab
        var r : Float = ap.dot( ab ) / ab.lengthsq();
        var closest : Vec2;

        if ( r < 0 ) {
            closest = line.a;
        } else if ( r > 1 ) {
            closest = line.b;
        } else {
            closest = line.a.add( ab.mul( r ) );
        }

        return closest;
    }

    // http://en.literateprograms.org/Box-Muller_transform_(C)
    public static function randomNorm( mean : Float, stddev : Float ) : Float {
        var result;

        if ( !useRandCache2 ) {
            useRandCache2 = true;
            result = boxMuller() * stddev + mean;
        } else {
            useRandCache2 = false;
            result = randCache2 * stddev + mean;
        }

        return result;
    }

    public static inline function powerCurve( start : Float, end : Float, rate : Float, progress : Float ) : Float {
        return 1 / ( 1 + Math.exp( -12 * (progress-0.5) ) ) * (end - start) + start;
    }

    public static inline function sign( x : Float ) : Int {
        var res;
        if ( x > 0 ) {
            res = 1;
        } else if ( x == 0 ) {
            res = 0;
        } else {
            res = -1;
        }
        return res;
    }

    private static function boxMuller() : Float {
        var r : Float = 0.0;
        var x : Float = 0;
        var y : Float = 0;

        while ( r == 0.0 || r > 1.0 ) {
            x = randomFloat( -1 , 1 );
            y = randomFloat( -1 , 1 );
            r = x * x + y * y;
        }
        var d = Math.sqrt( -2.0 * Math.log( r ) / r );
        randCache2 = y * d;
        return x * d;
    }

    private static var randCache2 : Float = 0;
    private static var useRandCache2 : Bool = false;

}
