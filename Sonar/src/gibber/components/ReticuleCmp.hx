package gibber.components;

import com.artemisx.Entity;
import com.artemisx.Component;

class ReticuleCmp implements Component
{
    @:isVar public var maxSpeed : Float;
    @:isVar public var player : Entity;

    public function new( player : Entity, ?maxSpeed : Float = 10 ) {
        this.player = player;
        this.maxSpeed = maxSpeed;
    }
}
