package sonar.components;

import com.artemisx.Component;

import gml.vector.Vec2f;

enum PingControllerState {
    No;
    Cooldown( n : UInt );
    Ping( mousePos : Vec2f );
}

enum FireTorpedoState {
    Unloaded;
    Guiding;
    Cooldown( n : UInt );
    Loaded;
    Fire( mousePos : Vec2f );
}

enum BlipControllerState {
    No;
    Cooldown( n : UInt );
    Blip;
}

class ControllerCmp implements Component 
{
    @:isVar public var moveUp    (default, set): Bool;
    @:isVar public var moveDown  (default, set): Bool;
    @:isVar public var moveLeft  (default, set): Bool;
    @:isVar public var moveRight (default, set): Bool;
    @:isVar public var createBlip : BlipControllerState;
    @:isVar public var createPing : PingControllerState;
    @:isVar public var torpedo : FireTorpedoState;

    @:isVar public var blipCooldown : UInt;
    @:isVar public var pingCooldown : UInt;
    @:isVar public var torpedoCooldown : UInt;

    public function new() {
        moveUp = moveDown = moveLeft = moveRight = false;
        createBlip = No;
        createPing = No;
        torpedo = Unloaded;

        blipCooldown = 20;
        pingCooldown = 20;
        torpedoCooldown = 60;
    }

    public function set_moveUp   ( up )     { return moveUp = up; }
    public function set_moveDown ( down )   { return moveDown = down; }
    public function set_moveLeft ( left )   { return moveLeft = left; }
    public function set_moveRight( right )  { return moveRight = right; }
}
