package gibber;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.EContainerCmp;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.TransitRequestCmp;
import gibber.scripts.TransitScript;
import utils.Polygon;
import utils.Vec2;

class EntityBuilder
    {
    public function new( g : God ) {
       god = g;
    }

    public function createTransitRequest( mover : Entity, destSector : Entity, transitScript : TransitScript ) : Entity {
        var e : Entity = world.createEntity();
        var tr = new TransitRequestCmp( mover, destSector, transitScript );
        
        e.addComponent( tr );
        
        world.addEntity( e );
        
        return e;
    }

    public function createSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( "sector:" + name );
        var lookCmp = new LookCmp();
        var regionCmp = new RegionCmp( pos, polygonAreas );
        var renderCmp = new RenderCmp();
        var containerCmp = new EContainerCmp();
        
        lookCmp.lookText = "This is some room #" + Std.random(1000);
        
        e.addComponent( nameCmp );
        e.addComponent( lookCmp );
        e.addComponent( regionCmp );
        e.addComponent( renderCmp );
        e.addComponent( containerCmp );
        
        world.addEntity( e );
        
        return e;
    }

    public function createPlayer( name : String ) : Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( god.sectors[0], new Vec2( 10, 10 ) );
        var renderCmp = new RenderCmp();
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( renderCmp );

        world.addEntity( e );
        
        return e;
    }

    public function createPortal( srcSector : Entity, destSector : Entity ) : Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( god.sectors[0], new Vec2( 20, 20 ) );
        var portalCmp = new PortalCmp( srcSector, destSector );
        var renderCmp = new RenderCmp();
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );
        e.addComponent( portalCmp );
        e.addComponent( renderCmp );

        world.addEntity( e );
        
        return e;
    }

    public function testAspectMatch() {
        var sig = Aspect.getAspectForAll( [PortalCmp] ).one( [PosCmp, TransitRequestCmp] ).exclude( [TransitRequestCmp] );
        var portal = createPortal( null, null );
        
        trace( Aspect.matches( sig, portal.componentBits ) );
    }
    
    public function testPolygon() {
        var p = new Polygon( [ new Vec2( -2, 1 ), new Vec2( 2, 3 ), new Vec2( 3, -2 ), new Vec2( -2, -2 ) ] );
        trace(p.getLineIntersection( new Vec2( -4, 0 ), new Vec2( 0, 0 ) ) );
    }

    var god : God;
    var world ( get_world, never ) : World;

    function get_world() : World {
        return god.world;
    }
}