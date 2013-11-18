package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;
import utils.Geo;

using gibber.Util;

@:rtti
class TraceCmp implements Component
{
    public static var VESTIGIAL_THRESHOLD : Float = 0.0001;

    @:isVar public var fadeMultiplier : Float; // 0 < fm < 1.0
    @:isVar public var traceType      : IntersectResult;
    @:isVar public var pos            : Vec2; // for RENDERING, we need to set an x and a y for the sprite
    @:isVar public var fadeAcc        : Float;

    public function new( fadeMultiplier : Float, traceType : IntersectResult, pos : Vec2 ) {
        this.fadeMultiplier = fadeMultiplier;
        this.traceType      = traceType;
        this.pos            = pos;
        this.fadeAcc        = 0.5;
    }
}
