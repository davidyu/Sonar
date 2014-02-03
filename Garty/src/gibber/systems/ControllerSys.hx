package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.ControllerCmp;

class ControllerSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [ControllerCmp] ) );
    }

    override public function initialize() : Void {
        controllerMapper = world.getMapper( ControllerCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var controller : ControllerCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );

            // clear state at end of update
            controller = controllerMapper.get( e );
            controller.moveUp = false;
            controller.moveDown = false;
            controller.moveLeft = false;
            controller.moveRight = false;
        }
    }

    var controllerMapper : ComponentMapper<ControllerCmp>;
}
