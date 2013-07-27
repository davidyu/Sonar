package gibber.gabby;
import com.artemisx.Entity;
import gibber.God;

class EntityResolver
{

    public function new( god : God ) {
        this.god = god;
    }
    
    public function spatialResolve( name : String, sectors : Array<Entity> ) : Entity {
        
    }
    
    var god : God;
    
}
