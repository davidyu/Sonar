package sonar.components;

import com.artemisx.Component;
import com.artemisx.Entity;

import gml.vector.Vec2f;

// this is for message passing: the PhysicsSys will calculate bounces and save results in a buffer using
// this data type; which may be processed by some other system.
enum LastTouched {
    Edge( a: Vec2f, b: Vec2f, col: Vec2f ); // FIXME
    Nothing;
}

@:rtti
class BounceCmp implements Component
{
    @:isVar public var dampenF : Float; //on every bounce, dampen?
    @:isVar public var lastTouched : LastTouched;

    public function new( dampenF : Float ) {
        this.dampenF = dampenF;
        this.lastTouched = Nothing;
    }
}
