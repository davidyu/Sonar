package gibber.components;

import com.artemisx.Component;

import utils.Vec2;

@:rtti
class TrailCmp implements Component
{
    @:isVar public var trailColor          : UInt;
    @:isVar public var fadeMultiplier      : Float;
    @:isVar public var direction           : Vec2;
    @:isVar public var speed               : Float; // pixels per frame

    public function new( direction : Vec2, speed : Float = 0.0, trailColor : UInt = 0xffffff, trailFadeMultiplier : Float = 0.9 ) {
        this.trailColor          = trailColor;
        this.fadeMultiplier      = trailFadeMultiplier;
        this.direction           = direction.normalize();
        this.speed               = speed;
    }

    public function getVelocity() {
        return direction.mul( speed );
    }
}
