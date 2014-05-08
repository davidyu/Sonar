package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.managers.ContainerMgr;
import gibber.components.ControllerCmp;
import gibber.components.PosCmp;
import gibber.components.ReticuleCmp;
import gibber.systems.EntityAssemblySys;
import gibber.systems.ClientSys;
import gibber.systems.RenderHUDSys;

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
        hudSys = world.getSystem( RenderHUDSys );
        containerMgr = world.getManager( ContainerMgr );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
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

            switch ( controller.createBlip ) {
                case Blip:
                    entityAssembler.createSonar( e.id, pos.sector, pos.pos );
                    netClient.sendSonarCreationEvent( pos.pos );
                    controller.createBlip = Cooldown( controller.blipCooldown );
                    hudSys.blipCoolingDown = true;
                case Cooldown( 0 ):
                    controller.createBlip = No;
                    hudSys.blipCoolingDown = false;
                case Cooldown( n ): // n  > 0
                    controller.createBlip = Cooldown( n - 1 );
                default:
            }

            switch ( controller.createPing ) {
                case Ping( mousePos ):
                    if ( camera != null ) {
                        var origin = Util.toScreen( SectorCoordinates( pos.pos, pos.sector ), camera );
                        var direction = mousePos.sub( origin );
                        entityAssembler.createSonarBeam( e.id, pos.sector, pos.pos, direction );
                        netClient.sendSonarBeamCreationEvent( pos.pos, direction  );
                        controller.createPing = Cooldown( controller.pingCooldown );
                        hudSys.pingCoolingDown = true;
                    }
                case Cooldown( 0 ):
                    controller.createPing = No;
                    hudSys.pingCoolingDown = false;
                case Cooldown( n ): // n > 0
                    controller.createPing = Cooldown( n - 1 );
                default:
            }

            switch ( controller.torpedo ) {
                case Fire( mousePos ):
                    // first, find reticule...this ought to be cached somewhere, because we only have 1 instance of the reticule
                    var target = null;
                    for ( e in containerMgr.getAllEntitiesOfContainer( pos.sector ) ) {
                        if ( e.getComponent( ReticuleCmp ) != null ) {
                            target = e;
                        }
                    }
                    if ( target != null ) {
                        entityAssembler.createTorpedo( e.id, DynamicTarget( target ), pos.sector, pos.pos );
                        // netClient.sendFireTorpedoEvent( pos.pos, target );
                        controller.torpedo = Cooldown( controller.torpedoCooldown );
                        hudSys.torpedoCoolingDown = true;
                    }
                case Cooldown( 0 ):
                    controller.torpedo = Unloaded;
                    hudSys.torpedoCoolingDown = false;
                case Cooldown( n ): // n > 0
                    controller.torpedo = Cooldown( n - 1 );
                default:
            }
        }
    }

    var controllerMapper : ComponentMapper<ControllerCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var entityAssembler : EntityAssemblySys;
    var hudSys : RenderHUDSys;
    var netClient : ClientSys;
    var camera : Entity;
    var containerMgr : ContainerMgr;

    var god : God;
}
