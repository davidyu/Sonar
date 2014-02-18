package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.ControllerCmp;
import gibber.components.PosCmp;
import gibber.systems.EntityAssemblySys;
import gibber.systems.ClientSys;

class ControllerSys extends EntitySystem
{
    public function new( god : God ) {
        super( Aspect.getAspectForAll( [ControllerCmp, PosCmp] ) );
        this.god = god;
    }

    override public function initialize() : Void {
        controllerMapper = world.getMapper( ControllerCmp );
        posMapper = world.getMapper( PosCmp );
        entityAssembler = world.getSystem( EntityAssemblySys );
        netClient = world.getSystem( ClientSys );
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

            if ( controller.createBlip ) {
                entityAssembler.createSonar( e.id, pos.sector, pos.pos );
                netClient.sendSonarCreationEvent( pos.pos );
                controller.createBlip = false;
            }

            switch ( controller.createPing ) {
                case Ping( mousePos ):
                    var origin = pos.pos;
                    var sectorPos = posMapper.get( pos.sector ).pos;
                    var direction = mousePos.sub( sectorPos ).sub( origin ); // wow
                    entityAssembler.createSonarBeam( pos.sector, origin, direction );
                    netClient.sendSonarBeamCreationEvent( origin, direction  );
                    controller.createPing = No;
                default:
            }
        }
    }

    var controllerMapper : ComponentMapper<ControllerCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var entityAssembler : EntityAssemblySys;
    var netClient : ClientSys;

    var god : God;
}
