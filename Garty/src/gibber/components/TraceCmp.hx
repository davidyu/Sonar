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

// this really shouldn't be necessary. If only Haxe gave us constructor overloading...
enum TraceConstructor {
    IR( ir : IntersectResult );
    TT( tt : TraceType );
}

@:rtti
class TraceCmp implements Component
{
    public static var VESTIGIAL_THRESHOLD : Float = 0.0001;

    @:isVar public var fadeMultiplier : Float; // 0 < fm < 1.0
    @:isVar public var traceType      : TraceType;
    @:isVar public var pos            : Vec2; // for RENDERING, we need to set an x and a y for the sprite
    @:isVar public var fadeAcc        : Float;

    public function new( fadeMultiplier : Float, pos : Vec2, traceConstructor : TraceConstructor ) {
        this.fadeMultiplier = fadeMultiplier;
        // the trace must eventually be a TraceType; we can do manual conversion from IntersectResult
        this.traceType      = switch ( traceConstructor ) {
                                case IR( ir ):
                                    switch( ir ) {
                                        case None         : Point( new Vec2( 0, 0 ) );
                                        case Point( p )   : Point( p );
                                        case Line( a, b ) : Line( a, b );
                                    }
                                case TT( tt ): tt;
                              };
        this.pos            = pos;
        this.fadeAcc        = 0.5;
    }
}
