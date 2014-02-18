package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.ControllerCmp;
import gibber.components.InputCmp;
import utils.Polygon;
import utils.Vec2;
import utils.Key;
import utils.Mouse;

class InputSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [InputCmp] ) );
    }

    override public function initialize() : Void {
        inputMapper = world.getMapper( InputCmp );
        controllerMapper = world.getMapper( ControllerCmp );
        Key.init();
        Mouse.init();
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var input : InputCmp;
        var controller : ControllerCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            input = inputMapper.get( e );
            controller = controllerMapper.get( e );

            controller.moveUp = Key.isDown( input.upKey );
            controller.moveDown = Key.isDown( input.downKey );
            controller.moveLeft = Key.isDown( input.leftKey );
            controller.moveRight = Key.isDown( input.rightKey );

            if ( Key.isToggled( input.blipTriggerKey ) ) {
                controller.createBlip = true;
            }

            if ( Key.isToggled( input.fireTorpedoKey ) ) {
                controller.fireTorpedo = Fire( Mouse.getMouseCoords() );
            }

            if ( Mouse.wasPressed() ) {
                controller.createPing = Ping( Mouse.getMouseCoords() );
            }

        } // end for ( i in actives.size)
    }

    var inputMapper : ComponentMapper<InputCmp>;
    var controllerMapper : ComponentMapper<ControllerCmp>;
}
