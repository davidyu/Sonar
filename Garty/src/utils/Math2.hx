package utils;

class Math2 {
    public static var PI : Float = 3.141592653589793238462643383279;
    public static inline function randomFloat( min : Float, max : Float ) : Float {
        return Math.random() * (max - min) + min;
    }
    public static inline function randomInt( min : Int, max : Int ) : Int {
        return Std.random( max - min ) + min;
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