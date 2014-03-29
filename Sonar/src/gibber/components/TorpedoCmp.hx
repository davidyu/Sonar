package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

enum TorpedoTarget {
    StaticTarget( pos: Vec2 );
    DynamicTarget( e : Entity );
}

@:rtti
class TorpedoCmp implements Component
{
    @:isVar public var playerId   : Int;
    @:isVar public var target     : TorpedoTarget;
    @:isVar public var accel      : Float;
    @:isVar public var maxSpeed   : Float;

    public function new( playerId : Int, target : TorpedoTarget, ?accel : Float = 2.0, ?maxSpeed : Float = 50.0 ) {
        this.playerId = playerId;
        this.accel    = accel;
        this.maxSpeed = maxSpeed;
        this.target = target;
    }
}
