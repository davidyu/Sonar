package gibber.components;

import com.artemisx.Component;
import com.artemisx.Entity;

import utils.Vec2;

// this is for message passing: the PhysicsSys will calculate bounces and save results in a buffer using
// this data type; which may be processed by some other system.
enum BounceMessage {
    JustBounced( edgeV1: Vec2, edgeV2: Vec2 );
    NoBounce;
}

@:rtti
class BounceCmp implements Component
{
    @:isVar public var dampenF : Float; //on every bounce, dampen?
    @:isVar public var bounced : BounceMessage;

    public function new( dampenF : Float ) {
        this.dampenF = dampenF;
        this.bounced = NoBounce;
    }
}
