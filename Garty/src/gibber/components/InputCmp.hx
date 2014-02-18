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
    @:isVar public var blipTriggerKey : UInt;
    @:isVar public var pingTriggerKey : UInt; // generally not used -- mapped to mouse click
    @:isVar public var fireTorpedoKey : UInt;

    public function new( up : UInt, down : UInt, left : UInt, right : UInt,
                         blipTriggerKey : UInt, pingTriggerKey : UInt,
                         fireTorpedoKey : UInt ) {
        this.upKey = up;
        this.downKey = down;
        this.leftKey = left;
        this.rightKey = right;
        this.blipTriggerKey = blipTriggerKey;
        this.pingTriggerKey = pingTriggerKey;
        this.fireTorpedoKey = fireTorpedoKey;
    }
}
