package gibber.components;
import com.artemisx.Component;

using gibber.Util;

@:rtti
class SonarCmp implements Component
{
    @:isVar public var growthRate : Float; //in pixels per second
    @:isVar public var maxRadius  : Float;

    public function new( growthRate : Float, maxRadius : Float ) {
        this.growthRate = growthRate;
        this.maxRadius  = maxRadius;
    }
}
