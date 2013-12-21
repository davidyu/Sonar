package utils.test;

import utils.Math2;
import utils.Vec2;

class CheckMath2 extends haxe.unit.TestCase {
    public function testCloseIntersectPoint() {
        // 1. dead-simple sanity checks
        var p, a, b, expected, result;
        p = new Vec2( 0, 0 );
        a = new Vec2( 0, 1 );
        b = new Vec2( 1, 1 );
        result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
        assertTrue( result.sub( a ).lengthsq() <= Math2.EPSILON );

        p = new Vec2( 1, 0 );
        a = new Vec2( 0, 1 );
        b = new Vec2( 1, 1 );
        result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
        assertTrue( result.sub( b ).lengthsq() <= Math2.EPSILON );

        p = new Vec2( 0.5, 0 );
        a = new Vec2( 0, 1 );
        b = new Vec2( 1, 1 );
        expected = new Vec2( 0.5, 1 );
        result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
        assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );

        for ( i in 0...10 ) {
            p = new Vec2( i / 10.0, 0 );
            a = new Vec2( 0, 1 );
            b = new Vec2( 1, 1 );
            expected = new Vec2( i / 10.0, 1 );
            result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
            assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );
        }

        // 2. edge case: line ab is a degenerate point
        for ( i in 0...100 ) {
            p = new Vec2( Math.random() * 1.0, 0 );
            a = new Vec2( 0, 0 );
            b = new Vec2( 0, 0 );
            expected = new Vec2( 0, 0 );
            result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
            assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );
        }

        for ( i in 0...100 ) {
            var x = Math.random() * 2.0 - 1.0;
            var y = Math.random() * 2.0 - 1.0;
            p = new Vec2( Math.random() * 2.0 - 1.0, Math.random() * 2.0 - 1.0 );
            a = new Vec2( x, y );
            b = new Vec2( x, y );
            expected = new Vec2( x, y );
            result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
            assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );
        }

        p = new Vec2( Math.random() * 1.0, 0 );
        a = new Vec2( 0, 0 );
        b = new Vec2( 0, 0 );
        expected = new Vec2( 0, 0 );
        result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );
        assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );

        // 3. verify the result is ALWAYS on the line
        for ( i in 0...100 ) {
            p = new Vec2( Math.random() * 2.0 - 1.0, Math.random() * 2.0 - 1.0 );
            a = new Vec2( Math.random() * 2.0 - 1.0, Math.random() * 2.0 - 1.0 );
            b = new Vec2( Math.random() * 2.0 - 1.0, Math.random() * 2.0 - 1.0 );
            result = Math2.getCloseIntersectPoint( p, { a : a, b : b } );

            // if result (c) is on line ab, it must satisfy: a + t*(AB) = c for some 0<=t<=1
            // this means the scalar projection of AC onto AB must be between 0 and 1
            var scalarProj = result.sub( a ).dot( b.sub( a ) ) / b.sub( a ).lengthsq();
            assertTrue( scalarProj >= 0.0 && scalarProj <= 1.0 );
        }
    }

    public function testRayLineIntersection() {
        var expected : Vec2;
        var result : Vec2;
        // simple collinear case
        assertTrue( Math2.getRayLineIntersection( { origin: new Vec2( 0, 0 ), direction: new Vec2( 1, 0 ) },
                                                  { a: new Vec2( 4, 0 ), b : new Vec2( 5, 0 ) } ) == Collinear );

        // simple parallel case
        assertTrue( Math2.getRayLineIntersection( { origin: new Vec2( 0, 1 ), direction: new Vec2( 1, 0 ) },
                                                  { a: new Vec2( 4, 0 ), b : new Vec2( 5, 0 ) } ) == None );

        // simple one point case
        expected = new Vec2( 0, 0 );
        var res = Math2.getRayLineIntersection( { origin: new Vec2( 0, -100 ), direction: new Vec2( 0, 1 ) },
                                                { a: new Vec2( -100, 0 ), b: new Vec2( 100, 0 ) } );

        // extract resulting vector from IntersectionResult; the more I look at this, the uglier I feel this is
        switch( res ) {
            case Point( point ): result = point;
            default:             result = new Vec2( 500, 500 ); // random
        }

        assertTrue( result.sub( expected ).lengthsq() <= Math2.EPSILON );
    }
}
