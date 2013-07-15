package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.TransitRequestCmp;
import gibber.scripts.TransitScript;

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
    
    public function createSector( name : String ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( "sector:" + name );
        var lookCmp = new LookCmp();
        var regionCmp = new RegionCmp();
        
        lookCmp.lookText = "This is some room #" + Std.random(1000);
        
        e.addComponent( nameCmp );
        e.addComponent( lookCmp );
        e.addComponent( regionCmp );
        
        world.addEntity( e );
        
        return e;
    }
    
    public function createPlayer( name : String ) : Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var posCmp = new PosCmp( god.sectors[0] );
        
        lookCmp.lookText = "This is the player";
        
        e.addComponent( posCmp );
        e.addComponent( lookCmp );

        world.addEntity( e );
        
        return e;
    }
    
    var god : God;
    var world ( get, never ) : World;
    
    function get_world() : World {
        return god.world;
    }
}