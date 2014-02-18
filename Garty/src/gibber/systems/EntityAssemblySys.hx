package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.Component;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.World;

import flash.utils.IDataInput2;
import flash.ui.Keyboard;

import gibber.components.ContainableCmp;
import gibber.components.StaticPosCmp;
import gibber.components.TeractNodeCmp;
import gibber.gabby.PortalEdge;
import gibber.gabby.SynTag;
import gibber.commands.MoveCmd;
import gibber.components.BounceCmp;
import gibber.components.CmdQueue;
import gibber.components.ContainerCmp;
import gibber.components.ControllerCmp;
import gibber.components.ClientCmp;
import gibber.components.InventoryCmp;
import gibber.components.InputCmp;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.NetworkPlayerCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.PosTrackerCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
import gibber.components.SyncCmp;
import gibber.components.TrailCmp;
import gibber.components.TimedEffectCmp;
import gibber.components.TransitRequestCmp;
import gibber.managers.ContainerMgr;
import gibber.scripts.TransitScript;
import gibber.teracts.LookTeract;
import gibber.teracts.MoveTeract;
import utils.Polygon;
import utils.Vec2;

using Lambda;

class EntityAssemblySys extends EntitySystem
{
    public function new() {
        super( Aspect.getEmpty() );
    }

    override public function initialize() : Void {
        containerMgr = world.getManager( ContainerMgr );
        regionMapper = world.getMapper( RegionCmp );
        posMapper = world.getMapper( PosCmp );
    }

    public function createNetworkPlayer( name: String, sector: Entity, position: Vec2, id: UInt ): Entity {
        var player = createPlayer( name, sector, position );
        var npCmp = new NetworkPlayerCmp( id );
#if ( debug && local )
        // render the network player in debug-local builds
#else
        player.removeComponent( RenderCmp ); // do not render the network player!
#end
        player.removeComponent( InputCmp ); // do not control the network player!
        player.removeComponent( SyncCmp ); // do not sync the network player!
        player.addComponent( npCmp );
        return player;
    }

    public function createPlayer( name: String, sector: Entity, position: Vec2 ): Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var nameCmp = new NameIdCmp( name, new SynTag( name, ["sub", name], SynType.NOUN ) );
        var posCmp = new PosCmp( sector, position );
        var renderCmp = new RenderCmp();
        var cmdCmp = new CmdQueue();
        var syncCmp = new SyncCmp();
        var controllerCmp = new ControllerCmp();
        var inventoryCmp = new InventoryCmp();
        var inputCmp = new InputCmp( Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT,
                                     Keyboard.SPACE, 1, Keyboard.Z );
        var containableCmp = new ContainableCmp( containerMgr, e, sector );

        e.addComponent( lookCmp );
        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );
        e.addComponent( cmdCmp );
        e.addComponent( inventoryCmp );
        e.addComponent( inputCmp );
        e.addComponent( syncCmp );
        e.addComponent( containableCmp );
        e.addComponent( controllerCmp );

        world.addEntity( e );

        return e;
    }

    // Look into this: I don't care about which sector I'm in when I'm creating a Sonar wave. It should ideally be inferred.
    public function createSonar( id : Int, sector : Entity, pos : Vec2 ) : Entity {
        var e = world.createEntity();

        var sonarCmp = new SonarCmp( id, 100.0, 100 );
        var posCmp = new PosCmp( sector, pos );
        var timedEffectCmp = new TimedEffectCmp( 1000, GlobalTickInterval );
        var renderCmp = new RenderCmp( 0xffffff );

        e.addComponent( timedEffectCmp );
        e.addComponent( sonarCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );

        world.addEntity( e );

        return e;
    }

    public function createClient( host : String, port : UInt ) {
        var e = world.createEntity();
        var client = new ClientCmp( host, port );

        e.addComponent( client );

        world.addEntity( e );

        return e;
    }

    // ugh: bad parameters again; see above.
    public function createSonarBeam( sector : Entity, pos: Vec2, direction : Vec2 ) : Entity {
        var e = world.createEntity();

        var posCmp = new PosCmp( sector, pos, true );
        var posTrackerCmp = new PosTrackerCmp( LastPos );
        posCmp.dp = direction.normalize().mul( 9.0 );
        var trailCmp = new TrailCmp( direction );
        var timedEffectCmp = new TimedEffectCmp( 2000, GlobalTickInterval );
        var renderCmp = new RenderCmp( 0xffffff );
        var bounceCmp = new BounceCmp( 1.0 );

        e.addComponent( timedEffectCmp );
        e.addComponent( trailCmp );
        e.addComponent( posCmp );
        e.addComponent( posTrackerCmp );
        e.addComponent( renderCmp );
        e.addComponent( bounceCmp );

        world.addEntity( e );

        return e;
    }

    // returns a sector without the RenderCmp
    public function createVirtualSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = createSector( name, pos, polygonAreas ).removeComponent( RenderCmp );
        return e;
    }

    public function createSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( name, new SynTag( name, [name], SynType.NOUN ) );
        var posCmp = new PosCmp( e, pos );
        var staticCmp = new StaticPosCmp();
        var lookCmp = new LookCmp();
        var regionCmp = new RegionCmp( polygonAreas );
        var renderCmp = new RenderCmp( 0x00ffff );
        var containerCmp = new ContainerCmp();

        lookCmp.lookText = "This is some room #" + Std.random(1000);

        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( staticCmp );
        e.addComponent( lookCmp );
        e.addComponent( regionCmp );
        e.addComponent( renderCmp );
        e.addComponent( containerCmp );

        world.addEntity( e );

        return e;
    }

    public function createEntityWithCmps( cmps : List<Component> )
    {
        var e = world.createEntity();

        for ( cmp in cmps ) {
            e.addComponent( cmp );
        }

        world.addEntity( e );
        return e;
    }

    var containerMgr : ContainerMgr;
    var regionMapper : ComponentMapper<RegionCmp>;
    var posMapper : ComponentMapper<PosCmp>;
}
