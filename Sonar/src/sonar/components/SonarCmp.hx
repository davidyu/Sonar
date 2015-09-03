package sonar.components;
import com.artemisx.Component;

using sonar.Util;

typedef Range = { start : Float, end : Float };

@:rtti
class SonarCmp implements Component
{
    @:isVar public var playerId   : Int;
    @:isVar public var growthRate : Float; //in pixels per second
    @:isVar public var maxRadius  : Float;

    @:isVar public var cullRanges : Array<Range>;

    public function new( playerId : Int, growthRate : Float, maxRadius : Float ) {
        this.growthRate = growthRate;
        this.maxRadius  = maxRadius;
        this.cullRanges = new Array<Range>();
        this.playerId   = playerId;
    }
}
