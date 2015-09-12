package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gml.vector.Vec2f;
import utils.Geo;

using sonar.Util;

enum TraceType {
    Point(point: Vec2f);
    Line(a:Vec2f, b:Vec2f);
    Mass(pos:Vec2f, size:Float);
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
