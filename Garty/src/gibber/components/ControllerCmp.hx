package gibber.components;

import com.artemisx.Component;

class ControllerCmp implements Component 
{
    @:isVar public var moveUp    (default, set): Bool;
    @:isVar public var moveDown  (default, set): Bool;
    @:isVar public var moveLeft  (default, set): Bool;
    @:isVar public var moveRight (default, set): Bool;

    public function new() {
        moveUp = moveDown = moveLeft = moveRight = false;
    }

    public function set_moveUp   ( up )     { return moveUp = up; }
    public function set_moveDown ( down )   { return moveDown = down; }
    public function set_moveLeft ( left )   { return moveLeft = left; }
    public function set_moveRight( right )  { return moveRight = right; }
}
