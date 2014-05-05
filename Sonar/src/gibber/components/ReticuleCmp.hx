package gibber.components;

import com.artemisx.Component;

class ReticuleCmp implements Component
{
    @:isVar public var maxSpeed : Float;

    public function new( ?maxSpeed : Float = 10 ) {
        this.maxSpeed = maxSpeed;
    }
}
