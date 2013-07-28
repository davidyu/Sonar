package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;

class NameIdCmp implements Component
{
    @:isVar public var tagEntityRef : Entity;
    @:isVar public var name ( default, default ) : String;

    public function new( n : String ) {
        this.name = n;
    }
    
    
}