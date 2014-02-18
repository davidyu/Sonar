package gibber.components;
import com.artemisx.Component;
import utils.Vec2;

@:rtti
class TorpedoCmp implements Component
{
    @:isVar public var playerId   : Int;
    @:isVar public var target     : Vec2;
    @:isVar public var accel      : Float;
    @:isVar public var maxSpeed   : Float;

    public function new( playerId : Int, target : Vec2, ?accel : Float = 2.0, ?maxSpeed : Float = 50.0 ) {
        this.playerId = playerId;
        this.accel    = accel;
        this.maxSpeed = maxSpeed;
        this.target = target;
    }
}
