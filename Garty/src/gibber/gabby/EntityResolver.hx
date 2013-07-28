package gibber.gabby;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.God;
import gibber.managers.ContainerMgr;

using Lambda;

class EntityResolver
{

    public function new( god : God ) {
        this.god = god;
    }
    
    public function initialize() : Void {
        cm = god.world.getManager( ContainerMgr );
        nameMapper = god.world.getMapper( NameIdCmp );

    }
    
    public function containerResolve( name : String, containers : Array<Entity> ) : Array<Entity> {
        var container = cm.getContainerOfEntity( e );
        
        if ( containers.exists( container ) ) {
            return e;
        }
        
        return null;
    }
    
    public function globalResolve( name : String ) : Array<Entity> {
        if ( cm.getContainerOfEntity( e ) != null ) {
            return e;
        }
        
        return null;
    }
    
    var god : God;
    var cm : ContainerMgr;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    
}
