package utils;

import gml.vector.Vec2f;

class Render
{
    // draws a good number of lines to fake the appearance of a circular arc
    public static function drawArc( center: Vec2f, radius : Float, startAngle : Float, arcAngle : Float, plot: Int->Int-> Void ) {
        var steps = Std.int( arcAngle * radius * 2 ); //adaptive sampling FTW!
        startAngle -= .25; // compensate; apparently 0 means start at 90 deg

        var twoPI = 2 * Math.PI;
        var angleStep = arcAngle/steps;

        var x : Int = Std.int( center.x + Math.cos( startAngle * twoPI ) * radius ),
            y : Int = Std.int( center.y + Math.sin( startAngle * twoPI ) * radius ),
            xx : Int, yy : Int;

        for ( i in 1...steps + 1 ) {
            var angle = startAngle + i * angleStep;
            xx = Std.int( center.x + Math.cos( angle * twoPI ) * radius );
            yy = Std.int( center.y + Math.sin( angle * twoPI ) * radius );
            bresenham( x, y, xx, yy, plot );
            x = xx;
            y = yy;
        }
    }

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
