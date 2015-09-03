package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

using sonar.Util;

enum CameraTarget {
    StaticTarget( pos: Vec2, sector: Entity );
    DynamicTarget( e : Entity );
}

@:rtti
class CameraCmp implements Component
{
    public var target : CameraTarget;
    public var viewportW : Int;
    public var viewportH : Int;

    public function new( target, ?viewportW, ?viewportH ) {
        this.target = target;

        if ( viewportW == null ) {
            this.viewportW = flash.Lib.current.stage.stageWidth;
        } else {
            this.viewportW = viewportW;
        }

        if ( viewportH == null ) {
            this.viewportH = flash.Lib.current.stage.stageHeight;
        } else {
            this.viewportH = viewportH;
        }
    }
}
