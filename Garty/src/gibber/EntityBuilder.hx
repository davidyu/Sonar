package gibber;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.ContainableCmp;
import gibber.components.StaticPosCmp;
import gibber.gabby.PortalEdge;
import gibber.gabby.Region;
import gibber.gabby.SynTag;
import gibber.commands.MoveCmd;
import gibber.components.CmdQueue;
import gibber.components.ContainerCmp;
import gibber.components.InventoryCmp;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.SynListCmp;
import gibber.components.TransitRequestCmp;
import gibber.managers.ContainerMgr;
import gibber.scripts.TransitScript;
import utils.Polygon;
import utils.Vec2;

using Lambda;

class EntityBuilder
    {
    public function new( g : God ) {
       god = g;
       world = god.world;
       containerMgr = god.world.getManager( ContainerMgr );
    }
    
    public function addPortalEdges( portal : Entity, edges : Array<PortalEdge> ) : Void {
        var portalCmp = portal.getComponent( PortalCmp );
        
        portalCmp.edges = portalCmp.edges.concat( edges );
        portal.addComponent( portalCmp );
        
        portal.getComponent( PosCmp ).regionStack.first().getComponent( RegionCmp ).portals.push( portal ); // temp add this portal to sector region

    }
    
    public function createWordRef( tag : SynTag ) {
        var e = world.createEntity();
        var tagCmp = new SynListCmp( tag );
        
        e.addComponent( tagCmp );
        
        world.addEntity( e );
        
        return e;
    }
    
    public function createPlayer( name : String ) : Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var nameCmp = new NameIdCmp( name );
        var posCmp = new PosCmp( god.sectors[0], new Vec2( 20, 20 ) );
        var renderCmp = new RenderCmp();
        var cmdCmp = new CmdQueue();
        var containerCmp = new ContainerCmp(); //temporary hack solution
        var inventoryCmp = new InventoryCmp();
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( lookCmp );
        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );
        e.addComponent( cmdCmp );
        e.addComponent( containerCmp );
        e.addComponent( inventoryCmp );

        world.addEntity( e );
        
        return e;
    }

    public function createPortal( name : String, sector : Entity, pos : Vec2 ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( name );
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( sector, pos );
        var staticCmp = new StaticPosCmp();
        var portalCmp = new PortalCmp();
        var regionCmp = new RegionCmp( [new Polygon( Vec2.getVecArray( [0, 0, 0, 10, 10, 10, 10, 0] ) )] );
        var contCmp = new ContainableCmp( containerMgr, sector, sector );
        var renderCmp = new RenderCmp( 0x00ff00 );
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( portalCmp );
        e.addComponent( staticCmp );
        e.addComponent( contCmp );
        e.addComponent( renderCmp );
        e.addComponent( regionCmp );
        e.addComponent( nameCmp );

        world.addEntity( e );
        
        return e;
    }

    public function createSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( "sector:" + name );
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
    
        public function createTransitRequest( mover : Entity, destSector : Entity, transitScript : TransitScript ) : Entity {
        var e : Entity = world.createEntity();
        var tr = new TransitRequestCmp( mover, destSector, transitScript );
        
        e.addComponent( tr );
        
        world.addEntity( e );
        
        return e;
    }
    
    public function testPolygon() {
        var p = new Polygon( [ new Vec2( -2, 1 ), new Vec2( 2, 3 ), new Vec2( 3, -2 ), new Vec2( -2, -2 ) ] );
        trace(p.getLineIntersection( new Vec2( -4, 0 ), new Vec2( 0, 0 ) ) );
    }

    var god : God;
    var world : World;
    var containerMgr : ContainerMgr;
}
