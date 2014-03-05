package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

using gibber.Util;

enum CameraTarget {
    StaticTarget( pos: Vec2, sector: Entity );
    DynamicTarget( e : Entity );
}

@:rtti
class CameraCmp implements Component
{
    var target : CameraTarget;

    public function new( target ) {
        this.target = target;
    }
}
