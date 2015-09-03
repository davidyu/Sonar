package sonar.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import sonar.components.ControllerCmp;
import sonar.components.InputCmp;
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

            if ( Key.isToggled( input.blipTriggerKey ) && controller.createBlip == No ) {
                controller.createBlip = Blip;
            }

            if ( Key.isToggled( input.loadTorpedoKey ) ) {
                if ( controller.torpedo == Unloaded ) {
                    controller.torpedo = Loaded;
                } else if ( controller.torpedo == Loaded ) {
                    controller.torpedo = Unloaded;
                }
            }

            if ( Mouse.isDown() ) {
                switch ( controller.torpedo ) {
                    case Loaded:
                        controller.torpedo = Fire( Mouse.getMouseCoords() );
                    default:
                }
            }

            if ( Mouse.wasPressed() ) {
                switch ( controller.torpedo ) {
                    case Guiding:
                        controller.torpedo = Cooldown( controller.torpedoCooldown );
                    case Unloaded:
                        if ( controller.createPing == No ) {
                            controller.createPing = Ping( Mouse.getMouseCoords() );
                        }
                    default:
                }
            }

        } // end for ( i in actives.size)
    }

    var inputMapper : ComponentMapper<InputCmp>;
    var controllerMapper : ComponentMapper<ControllerCmp>;
}
