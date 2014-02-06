package gibber;
import com.artemisx.Aspect;
import com.artemisx.Component;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.World;
import flash.utils.IDataInput2;
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
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.NetworkPlayerCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.PosTrackerCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
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

class EntityBuilder
{
    public function new( g : God ) {
       god = g;
       world = god.world;

       init();
    }

    public function init() : Void {
        containerMgr = god.world.getManager( ContainerMgr );
        regionMapper = world.getMapper( RegionCmp );
        posMapper = world.getMapper( PosCmp );
    }

    public function addPortalEdges( portal : Entity, edges : Array<PortalEdge> ) : Void {
        var portalCmp = portal.getComponent( PortalCmp );
        var portalRegionCmp = regionMapper.get( portal );
        var portalPosCmp = posMapper.get( portal );

        portalCmp.edges = portalCmp.edges.concat( edges );
        portal.addComponent( portalCmp );

        //portalRegionCmp.parent = portalPosCmp.sector;
        //portalRegionCmp.adj.push( portalPosCmp.sector );
        for ( e in edges ) {
            if ( !portalRegionCmp.adj.has( e.pSrc ) ) {
                portalRegionCmp.adj.push( e.pSrc );
            }
            if ( !portalRegionCmp.adj.has( e.pDest ) ) {
                portalRegionCmp.adj.push( e.pDest );
            }
            regionMapper.get( e.pSrc ).adj.push( portal );
        }
    }

    public function doubleEdge( portal : Entity, s1 : Entity, s2 : Entity ) : Void {
        addPortalEdges( portal, [new PortalEdge( s1, s2, god.sf.createScript( "transit" ) )] );
        addPortalEdges( portal, [new PortalEdge( s2, s1, god.sf.createScript( "transit" ) )] );
    }

    public function createNetworkPlayer( name: String, sector: Entity, position: Vec2, id: UInt ): Entity {
        var player = createPlayer( name, sector, position );
        var npCmp = new NetworkPlayerCmp( id );
        player.removeComponent( RenderCmp ); // do not render the network player!
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
        var controllerCmp = new ControllerCmp();
        var inventoryCmp = new InventoryCmp();

        e.addComponent( lookCmp );
        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );
        e.addComponent( cmdCmp );
        e.addComponent( inventoryCmp );
        e.addComponent( controllerCmp );

        world.addEntity( e );

        return e;
    }

    public function createPortal( name : String, pos : Vec2 ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( name, new SynTag( name, new Array<String>(), SynType.NOUN ) );
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( null, pos );
        var staticCmp = new StaticPosCmp();
        var portalCmp = new PortalCmp();
        var regionCmp = new RegionCmp( [new Polygon( Vec2.getVecArray( [0, 0, 0, 10, 10, 10, 10, 0] ) )] );
        //var contCmp = new ContainableCmp( containerMgr, e, null );
        var renderCmp = new RenderCmp( 0x00ff00 );

        lookCmp.lookText = "This is the player";

        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( portalCmp );
        e.addComponent( staticCmp );
        //e.addComponent( contCmp );
        e.addComponent( renderCmp );
        e.addComponent( regionCmp );
        e.addComponent( nameCmp );

        world.addEntity( e );

        return e;
    }

    // Look into this: I don't care about which sector I'm in when I'm creating a Sonar wave. It should ideally be inferred.
    public function createSonar( sector : Entity, pos : Vec2 ) : Entity {
        var e = world.createEntity();

        var sonarCmp = new SonarCmp( 100.0, 100 );
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
        var teractNodeCmp = new TeractNodeCmp( [ new MoveTeract( god, null ) ] );
        var renderCmp = new RenderCmp( 0x00ffff );
        var containerCmp = new ContainerCmp();

        lookCmp.lookText = "This is some room #" + Std.random(1000);

        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( staticCmp );
        e.addComponent( lookCmp );
        e.addComponent( regionCmp );
        e.addComponent( teractNodeCmp );
        e.addComponent( renderCmp );
        e.addComponent( containerCmp );

        world.addEntity( e );

        return e;
    }

    public function createTransitRequest( mover : Entity, destSector : Entity, transitScript : TransitScript ) : Entity {
        var e : Entity = world.createEntity();
        var tr = new TransitRequestCmp( mover, destSector, transitScript );

        e.addComponent( tr );

        world.addEntity( e );

        return e;
    }

    public function createObject( name : String, pos : Vec2, ?lookText : String ) : Entity
    {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var nameIdCmp = new NameIdCmp( name, new SynTag( name, new Array<String>(), SynType.NOUN ) );
        var posCmp = new PosCmp( god.sectors[0], pos );
        var staticCmp = new StaticPosCmp();
        var renderCmp = new RenderCmp();
        var containableCmp = new ContainableCmp( containerMgr, god.sectors[0], god.sectors[0] );

        if ( lookText == "" || lookText == null ) {
            var firstChar = name.charAt( 0 );
            if ( firstChar == "a" || firstChar == "e" || firstChar == "i" || firstChar == "o" || firstChar == "u" ) {
                lookCmp.lookText = "An " + name.toLowerCase();
            } else {
                lookCmp.lookText = "A " + name.toLowerCase();
            }
        } else {
            lookCmp.lookText = lookText;
        }

        e.addComponent( nameIdCmp );
        e.addComponent( lookCmp );
        e.addComponent( posCmp );
        e.addComponent( staticCmp );
        e.addComponent( renderCmp );
        e.addComponent( containableCmp );

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

    // this is pretty bad
    public function pipeDebug( str ) {
        god.debugPrintln( str );
    }

    var god : God;
    var world : World;
    var containerMgr : ContainerMgr;

    var regionMapper : ComponentMapper<RegionCmp>;
    var posMapper : ComponentMapper<PosCmp>;
}
