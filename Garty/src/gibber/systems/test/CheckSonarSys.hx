package gibber.systems.test;

import utils.Math2;
import utils.Vec2;
import gibber.systems.SonarSys;

@:access(gibber.systems.SonarSys) // all your private methods are belong to me
class CheckSonarSys extends haxe.unit.TestCase {
    var sonarSys : SonarSys;

    override public function setup() {
        sonarSys = new SonarSys();
    }

    public function testPointToRadian() {
        var center: Vec2;
        var point: Vec2;

        center = new Vec2( 0, 0 );
        point = new Vec2( 0, 1 );
        assertTrue( sonarSys.pointToRadian( center, point, false ) <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 2 ) / 2, Math.sqrt( 2 ) / 2 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 0.785398163 <= Math2.EPSILON );

        point = new Vec2( 1, 0 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 1.57079633 <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 2.35619449 <= Math2.EPSILON );

        point = new Vec2( 0, -1 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - Math.PI <= Math2.EPSILON );

        point = new Vec2( -Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 3.92699082 <= Math2.EPSILON );

        point = new Vec2( -1, 0 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 4.71238898 <= Math2.EPSILON );

        point = new Vec2( 0.5, Math.sqrt( 3 ) / 2 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 0.523598776 <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 3 ) / 2,  0.5 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 1.04719755 <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 3 ) / 2,  -0.5 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 2.0943951 <= Math2.EPSILON );

        point = new Vec2( 0.5, -Math.sqrt( 3 ) / 2  );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 2.61799388 <= Math2.EPSILON );

        point = new Vec2( -0.5, -Math.sqrt( 3 ) / 2  );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 3.66519143 <= Math2.EPSILON );

        point = new Vec2( -Math.sqrt( 3 ) / 2, -0.5 );
        assertTrue( Math.abs( sonarSys.pointToRadian( center, point, false ) ) - 4.1887902 <= Math2.EPSILON );
    }

    public function testRadianDiff() {
        var a: Float,
            b: Float,
            expected: Float;

        a = Math2.degToRad( 0.0 );
        b = Math2.degToRad( 60.0 );
        expected = Math2.degToRad( 60.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 50.0 );
        b = Math2.degToRad( 100.0 );
        expected = Math2.degToRad( 50.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 270.0 );
        b = Math2.degToRad( 300.0 );
        expected = Math2.degToRad( 30.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 300.0 );
        b = Math2.degToRad( 270.0 );
        expected = Math2.degToRad( -30.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 30.0 );
        b = Math2.degToRad( 330.0 );
        expected = Math2.degToRad( -60 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 270.0 );
        b = Math2.degToRad( 0.0 );
        expected = Math2.degToRad( 90.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 330.0 );
        b = Math2.degToRad( 0.0 );
        expected = Math2.degToRad( 30.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 10.0 );
        b = Math2.degToRad( 350.0 );
        expected = Math2.degToRad( -20.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 330.0 );
        b = Math2.degToRad( 90.0 );
        expected = Math2.degToRad( 120.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        a = Math2.degToRad( 50.0 );
        b = Math2.degToRad( 40.0 );
        expected = Math2.degToRad( -10.0 );
        assertTrue( Math.abs( sonarSys.radianDiff( a, b ) - expected ) <= Math2.EPSILON );

        // undefined behavior: what should the sign of degreeDiff be in these cases?
        a = 0.0;
        b = 180.0;

        a = 270.0;
        b = 180.0;
    }
}
