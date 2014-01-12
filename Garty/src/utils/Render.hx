package utils;

class Render
{
    // very smart, complete, and reasonably well-optimized algorithm courtesy of wikipedia
    public static function bresenham( x0, y0, x1, y1, plot: Int->Int-> Void ) {
        var dx : Float = Math.abs( x1 - x0 );
        var dy : Float = Math.abs( y1 - y0 );

        var xStep : Int = 0;
        var yStep : Int = 0;

        // this takes care of all possible slopes
        if ( x0 < x1 ) xStep = 1 else xStep = -1;
        if ( y0 < y1 ) yStep = 1 else yStep = -1;

        var err : Float = dx - dy; // in the vanilla algorithm, if Math.abs(err) > 0.5 then we increment y by yStep

        while ( true ) {
            plot( x0, y0 );
            if ( x0 == x1 && y0 == y1 ) break;

            var e2 = err * 2;
            if ( e2 > -dy ) { // -> 2dx > dy ( slope is greater than 1/2 )
                err -= dy;
                x0 += xStep;
            }

            if ( x0 == x1 && y0 == y1 ) {
                plot( x0, y0 );
                break;
            }

            if ( e2 < dx ) { // -> 2dy > dx ( slope is less than 2 )
                err += dx;
                y0 += yStep;
            }
        }
    }
}
