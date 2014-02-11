package gibber.components;

import com.artemisx.Component;

import utils.Vec2;

enum PingControllerState {
    No;
    Ping( mousePos : Vec2 );
}

class ControllerCmp implements Component 
{
    @:isVar public var moveUp    (default, set): Bool;
    @:isVar public var moveDown  (default, set): Bool;
    @:isVar public var moveLeft  (default, set): Bool;
    @:isVar public var moveRight (default, set): Bool;
    @:isVar public var createBlip : Bool;
    @:isVar public var createPing : PingControllerState;

    public function new() {
        moveUp = moveDown = moveLeft = moveRight = false;
        createBlip = false;
        createPing = No;
    }

    public function set_moveUp   ( up )     { return moveUp = up; }
    public function set_moveDown ( down )   { return moveDown = down; }
    public function set_moveLeft ( left )   { return moveLeft = left; }
    public function set_moveRight( right )  { return moveRight = right; }
}
