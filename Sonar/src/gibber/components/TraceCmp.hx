package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;
import utils.Geo;

using gibber.Util;

enum TraceType {
    Point(point: Vec2);
    Line(a:Vec2, b:Vec2);
    Mass(pos:Vec2, size:Float);
}

@:rtti
class TraceCmp implements Component
{
    public static var VESTIGIAL_THRESHOLD : Float = 0.0001;

    @:isVar public var fadeMultiplier : Float; // 0 < fm < 1.0
    @:isVar public var traceType      : TraceType;
    @:isVar public var fadeAcc        : Float;

    public function new( fadeMultiplier : Float, traceType : TraceType ) {
        this.fadeMultiplier = fadeMultiplier;
        this.traceType      = traceType;
        this.fadeAcc        = 0.9;
    }
}
