package gibber;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.ContainableCmp;
import gibber.gabby.SynTag;
import gibber.commands.MoveCmd;
import gibber.components.CmdQueue;
import gibber.components.ContainerCmp;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.gabby.components.SynListCmp;
import gibber.components.TransitRequestCmp;
import gibber.managers.ContainerMgr;
import gibber.scripts.TransitScript;
import utils.Polygon;
import utils.Vec2;

class EntityBuilder
    {
    public function new( g : God ) {
       god = g;
       world = god.world;
       containerMgr = god.world.getManager( ContainerMgr );
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
        
        cmdCmp.enqueue( god.cmdFactory.createCmd( "move", [e, new Vec2( 100, 20 )] ) );
        cmdCmp.enqueue( god.cmdFactory.createCmd( "move", [e, new Vec2( 20, 20 )] ) );
        cmdCmp.enqueue( god.cmdFactory.createCmd( "move", [e, new Vec2( 100, 20 )] ) );
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( renderCmp );
        e.addComponent( cmdCmp );

        world.addEntity( e );
        
        return e;
    }

    public function createPortal( srcSector : Entity, destSector : Entity ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( "door1" );
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( srcSector, new Vec2( 20, 20 ) );
        var portalCmp = new PortalCmp( srcSector, destSector );
        var contCmp = new ContainableCmp( containerMgr, srcSector, srcSector );
        var renderCmp = new RenderCmp();
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( portalCmp );
        e.addComponent( contCmp );
        e.addComponent( renderCmp );
        e.addComponent( nameCmp );

        world.addEntity( e );
        
        return e;
    }

    public function testAspectMatch() {
        var sig = Aspect.getAspectForAll( [PortalCmp] ).one( [PosCmp, TransitRequestCmp] ).exclude( [TransitRequestCmp] );
        var portal = createPortal( null, null );
        
        trace( Aspect.matches( sig, portal.componentBits ) );
    }

    public function createSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( "sector:" + name );
        var lookCmp = new LookCmp();
        var regionCmp = new RegionCmp( pos, polygonAreas );
        var renderCmp = new RenderCmp();
        var containerCmp = new ContainerCmp();
        
        lookCmp.lookText = "This is some room #" + Std.random(1000);
        
        e.addComponent( nameCmp );
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