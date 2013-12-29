package utils;

class RadianHelper
{
    // returns true if a is after b clockwise, and false otherwise
    private static function isAfterCW( a: Float, b: Float ): Bool {
        return diff( a, b ) < 0;
    }

    // returns f, where |f| is the shortest distance (in radians) between a and b
    // and f > 0 if b follows a clockwise and f < 0 if a follows b clockwise
    private static function diff( a: Float, b: Float ): Float {
        var diff = b - a;
        if ( diff >  Math.PI ) diff -= Math.PI * 2; // as expected, b follows a CW, but we should go CCW for the smaller angle
        if ( diff < -Math.PI ) diff += Math.PI * 2; // edge case: going from a to b we pass the y-axis separating quadrants 1 and 4. So we apply a magical 360 error correcting factor

        return diff;
    }
}
