package sonar.components;

import com.artemisx.Component;

import utils.Vec2;

@:rtti
class TrailCmp implements Component
{
    @:isVar public var playerId   : Int;
    @:isVar public var trailColor          : UInt;
    @:isVar public var fadeMultiplier      : Float;
    @:isVar public var direction           : Vec2;

    public function new( playerId : Int, direction : Vec2, trailColor : UInt = 0xffffff, trailFadeMultiplier : Float = 0.9 ) {
        this.trailColor          = trailColor;
        this.fadeMultiplier      = trailFadeMultiplier;
        this.direction           = direction.normalize();
        this.playerId            = playerId;
    }
}
