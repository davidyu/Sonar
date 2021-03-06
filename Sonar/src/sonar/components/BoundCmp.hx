package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;

using sonar.Util;

enum Bound {
    Circle( radius : Float );
    Rect( w : Float, h : Float );
}

@:rtti
class BoundCmp implements Component
{
    public var bound : Bound;

    public function new( bound ) {
        this.bound = bound;
    }
}
