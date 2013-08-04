package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.God;
import gibber.managers.ContainerMgr;
import gibber.managers.NameRegistry;

using Lambda;

class EntityResolver
{

    public function new( god : God ) {
        this.god = god;
        initialize();
    }
    
    public function initialize() : Void {
        cm = god.world.getManager( ContainerMgr );
        nr = god.world.getManager( NameRegistry );
        nameMapper = god.world.getMapper( NameIdCmp );

    }
    
    public function containerResolve( name : String, containers : Array<Entity> ) : Array<Entity> {
        //var container = cm.getContainerOfEntity( e );
        //
        //if ( containers.exists( container ) ) {
            //return e;
        //}
        //
        return null;
    }
    
    public function globalResolve( name : String ) : Array<Entity> {
        var e = nr.getEntity( name );
        var res = null;
        
        if ( e != null ) {
            res = [e];
        }
        return res;
    }
    
    var god : God;
    var cm : ContainerMgr;
    var nr : NameRegistry;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    
}
