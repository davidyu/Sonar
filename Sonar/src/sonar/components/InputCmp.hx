package sonar.components;
import com.artemisx.Component;

using sonar.Util;

@:rtti
class InputCmp implements Component
{
    @:isVar public var upKey    : UInt;
    @:isVar public var downKey  : UInt;
    @:isVar public var leftKey  : UInt;
    @:isVar public var rightKey : UInt;
    @:isVar public var blipTriggerKey : UInt;
    @:isVar public var pingTriggerKey : UInt; // not used in release -- mapped to mouse click
    @:isVar public var loadTorpedoKey : UInt;
    @:isVar public var fireTorpedoKey : UInt; // not used in release -- mapped to mouse click

    public function new( up : UInt, down : UInt, left : UInt, right : UInt,
                         blipTriggerKey : UInt, pingTriggerKey : UInt,
                         loadTorpedoKey : UInt, fireTorpedoKey : UInt ) {
        this.upKey = up;
        this.downKey = down;
        this.leftKey = left;
        this.rightKey = right;
        this.blipTriggerKey = blipTriggerKey;
        this.pingTriggerKey = pingTriggerKey;
        this.fireTorpedoKey = fireTorpedoKey;
        this.loadTorpedoKey = loadTorpedoKey;
    }
}
