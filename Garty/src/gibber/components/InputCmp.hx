package gibber.components;
import com.artemisx.Component;

using gibber.Util;

@:rtti
class InputCmp implements Component
{
    @:isVar public var upKey    : UInt;
    @:isVar public var downKey  : UInt;
    @:isVar public var leftKey  : UInt;
    @:isVar public var rightKey : UInt;
    @:isVar public var sonarTriggerKey : UInt;
    @:isVar public var pingTriggerKey  : UInt; // generally not used -- mapped to mouse click

    public function new( up : UInt, down : UInt, left : UInt, right : UInt,
                         sonarTriggerKey : UInt, pingTriggerKey : UInt ) {
        this.upKey = up;
        this.downKey = down;
        this.leftKey = left;
        this.rightKey = right;
        this.sonarTriggerKey = sonarTriggerKey;
        this.pingTriggerKey = pingTriggerKey;
    }
}
