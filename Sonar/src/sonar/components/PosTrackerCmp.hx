package sonar.components;
import com.artemisx.Component;
import gml.vector.Vec2f;

using sonar.Util;

enum TrackingBehavior {
    LastPos;
    PosList( num : Int );
}

@:rtti
class PosTrackerCmp implements Component
{
    @:isVar public var behavior : TrackingBehavior;

    private var lastPosArray : Array<Vec2f>;
    private var lastPos : Vec2f;

    public function new( behavior : TrackingBehavior ) {
        switch( behavior ) {
            case LastPos: lastPos = new Vec2f( 0, 0 );
            case PosList( n ):
                lastPosArray = new Array<Vec2f>();
        }

        this.behavior = behavior;
    }

    public function setLastPosition( pos : Vec2f ) {
        switch( behavior ) {
            case LastPos:
                lastPos = pos;
            case PosList( n ):
                if ( lastPosArray.length == n ) {
                    lastPosArray.pop();
                }
                lastPosArray.unshift( pos );
        }
    }

    public function getLastPosition( nth : Int = 0 ) : Vec2f {
        switch( this.behavior ) {
            case LastPos:
                if ( nth > 0 ) throw "this component is not tracking multiple position values! Rebuild the component with PosList instead!";
                return lastPos;
            case PosList( n ):
                if ( nth > n - 1 ) throw "out of bounds! This component only tracks $n positions, but you're asking for $nth!";
                return lastPosArray[ nth > lastPosArray.length - 1 ? lastPosArray.length - 1 : nth ];
        }
    }
}
