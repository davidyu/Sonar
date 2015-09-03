package sonar.components;

import com.artemisx.Component;

class NetworkPlayerCmp implements Component
{
    @:isVar public var id: UInt;
    public function new( id: UInt ) {
        this.id = id;
    }
}
