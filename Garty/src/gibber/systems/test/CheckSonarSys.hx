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
        assertTrue( sonarSys.pointToRadian( center, point ) <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 2 ) / 2, Math.sqrt( 2 ) / 2 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 0.785398163 <= Math2.EPSILON );

        point = new Vec2( 1, 0 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 1.57079633 <= Math2.EPSILON );

        point = new Vec2( Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 2.35619449 <= Math2.EPSILON );

        point = new Vec2( 0, -1 );
        assertTrue( sonarSys.pointToRadian( center, point ) - Math.PI <= Math2.EPSILON );

        point = new Vec2( -Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 3.92699082 <= Math2.EPSILON );

        point = new Vec2( -1, 0 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 4.71238898 <= Math2.EPSILON );

        point = new Vec2( -Math.sqrt( 2 ) / 2, Math.sqrt( 2 ) / 2 );
        assertTrue( sonarSys.pointToRadian( center, point ) - 5.49778714 <= Math2.EPSILON );
    }
}
