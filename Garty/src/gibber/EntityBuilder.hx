package gibber;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.ContainableCmp;
import gibber.components.StaticPosCmp;
import gibber.gabby.PortalEdge;
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
           
        portalRegionCmp.adj.push( portalPosCmp.sector );
        for ( e in edges ) {
            portalRegionCmp.adj.push( posMapper.get( e.pDest ).sector );
        }
        regionMapper.get( portalPosCmp.sector ).adj.push( portal );
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
    
    public function createObject( name : String, pos : Vec2 ) : Entity
    {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var nameIdCmp = new NameIdCmp( "chest" );
        var posCmp = new PosCmp( god.sectors[0], pos );
        var staticCmp = new StaticPosCmp();
        var renderCmp = new RenderCmp();
        var containableCmp = new ContainableCmp( containerMgr, god.sectors[0], god.sectors[0] );

        var firstChar = name.charAt( 0 );
        if ( firstChar == "a" || firstChar == "e" || firstChar == "i" || firstChar == "o" || firstChar == "u" ) {
            lookCmp.lookText = "An " + name.toLowerCase();
        } else {
            lookCmp.lookText = "A " + name.toLowerCase();
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

    var god : God;
    var world : World;
    var containerMgr : ContainerMgr;
    
    var regionMapper : ComponentMapper<RegionCmp>;
    var posMapper : ComponentMapper<PosCmp>;
}
