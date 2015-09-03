package sonar.components;

import com.artemisx.Component;

enum DestructibleState {
    Normal( health : UInt );
    Destroyed;
    Respawning( tick : UInt );
}

class DestructibleCmp implements Component
{
    @:isVar public var state : DestructibleState;

    // stats
    @:isVar public var deaths: UInt;
    @:isVar public var kills : UInt;

    public function new( health: UInt ) {
        this.deaths = 0;
        this.kills = 0;
        this.state = Normal( health );
    }
}
