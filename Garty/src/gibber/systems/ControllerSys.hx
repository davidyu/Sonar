package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.ControllerCmp;
import gibber.components.PosCmp;

class ControllerSys extends EntitySystem
{
    public function new( god : God ) {
        super( Aspect.getAspectForAll( [ControllerCmp, PosCmp] ) );
        this.god = god;
    }

    override public function initialize() : Void {
        controllerMapper = world.getMapper( ControllerCmp );
        posMapper = world.getMapper( PosCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var controller : ControllerCmp;
        var pos : PosCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            controller = controllerMapper.get( e );
            pos = posMapper.get( e );

            var speed = 1.0;
            if ( controller.moveUp ) {
                pos.dp.y = -speed;
            }

            if ( controller.moveDown ) {
                pos.dp.y = speed;
            }

            if ( controller.moveLeft ) {
                pos.dp.x = -speed;
            }

            if ( controller.moveRight ) {
                pos.dp.x = speed;
            }

            if ( controller.createSonar ) {
                god.entityBuilder.createSonar( pos.sector, pos.pos );
                god.sendSonarCreationEvent( pos.pos );
                controller.createSonar = false;
            }
        }
    }

    var controllerMapper : ComponentMapper<ControllerCmp>;
    var posMapper : ComponentMapper<PosCmp>;

    var god : God;
}
